module BinaryHelpers
  def colon_to_bytes(str)
    str.split(':').collect(&:hex)
  end

  def bytes_to_colon(_array_of_bytes)
    bytes.map(&:hex)
  end
end
