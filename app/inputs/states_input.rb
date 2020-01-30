class StatesInput < SimpleForm::Inputs::CollectionSelectInput
  def collection
    CS.states(:us).keys
  end
end
