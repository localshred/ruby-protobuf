module WordUtils
  
  # Takes a string or symbol and camelizes it:
  # Expects: some_long_name
  # Returns: SomeLongName
  def self.camelize(str)
    if (str.is_a? Array)
      str.map{|p| camelize(p.to_s) }.join('::')
    else
      str = str.to_s.gsub(/(?:\A|_)(\w)/) { $1.upcase }
    end
  end

  # Expects: SomeLongName
  # Returns: some_long_name
  def self.underscore(str)
    str.to_s.gsub(/\B[A-Z]/, '_\&').downcase
  end
  
  # Expects: SomeModule::Path
  # Returns: some_module/path
  def self.module_to_path(str)
    pkg = str.to_s.split('::')
    pkg.map{|e| underscore(e) }.join('/')
  end
  
  # Expects: PackageA.PackageB
  # Returns: package_a/package_b
  def self.package_to_path(str)
    str.to_s.split('.').map{|e| underscore(e) }.join('/')
  end
  
  # Takes a class constant and converts it to a string resembling a java package path
  # Expects: ModA::ModB::MyService
  # Returns: mod_a.mod_b.MyService
  def self.packagize(klass)
    klass = klass.to_s.split('::') unless klass.is_a? Array
    klass_name = klass.pop
    klass.map{|e| underscore(e) }.join('.') + ".#{klass_name}"
  end
  
  # The reverse of packagize. Takes a string resembling a java package path
  # and converts it into a module constant
  # Expects: mod_a.mod_b.MyService
  # Returns: ModA::ModB::MyService
  def self.moduleize(str)
    str = str.join('.') if str.is_a? Array
    str.split('.').map{|e| camelize(e) }.join('::')
  end
  
  def self.constantize(klass)
    constants = moduleize(klass).split('::')
    constants.inject(Module.const_get(constants.shift)) {|const, obj| const.const_get(obj) }
  end
  
end