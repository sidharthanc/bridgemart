require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'
require 'rmagick'
require 'Rdmtx'
require 'tempfile'

class BarcodeService
  attr_reader :prefix, :style

  def initialize(style: nil, prefix: nil)
    @style = style || :basic
    @prefix = prefix
  end

  def generator_from_style
    case style.to_s
    when "matrix", "2d"
      DataMatrix.new(self)
    else
      Basic.new(self)
    end
  end

  def generate(value)
    return unless value

    generator_from_style.generate(prepare_value(value))
  end

  def prepare_value(value)
    return value unless prefix

    [prefix, value].flatten.compact.join
  end

  class Basic < SimpleDelegator
    def generate(value)
      return unless value

      barcode = Barby::Code128.new(value, "A")
      output_file = Tempfile.new
      output_file.binmode
      output_file.write(barcode.to_png)
      output_file.close
      output_file
    end
  end

  class DataMatrix < SimpleDelegator
    def generate(value)
      return unless value

      i = Rdmtx.new.encode(value, 5, 5, DmtxSymbolSquareAuto)
      output_file = Tempfile.new(['datamatrix', '.jpg'])
      output_file.binmode
      i.write(output_file.path)
      output_file
    end
  end
end
