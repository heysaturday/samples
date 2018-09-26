class Hash
  def requires!(keys)
    differences = keys - self.keys
    unless differences.empty?
      raise ArgumentError, "params must contain: #{keys.inspect}, but is missing #{differences.inspect}" 
    end
  end
end