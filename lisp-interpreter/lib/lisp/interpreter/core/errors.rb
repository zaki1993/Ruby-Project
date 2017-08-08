# ErrorMessages module contains different error messages
module ErrorMessages
  def unbalanced_brackets_error
    'error signaled: unbalanced brackets'
  end

  def unbalanced_quotes_error
    'error signaled: unbalanced quotes'
  end

  def arg_err_build(exp, got)
    'Incorrect number of arguments, expected ' + exp.to_s + ' got ' + got.to_s
  end

  def no_procedure_build(name)
    'No procedure found ' + name.to_s
  end

  def unbound_symbol_err(symbol)
    'Unbound symbol ' + symbol.to_s
  end

  def data_type_err(exp, got)
    'Invalid data type, expected ' + exp.to_s + ' got ' + got.to_s
  end
end

class SchemeException < RuntimeError
end
