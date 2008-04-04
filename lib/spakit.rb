module ActionController
  
  class Base
    alias :rails_redirect_to :redirect_to
    alias :rails_render :render
    
    def redirect_to(options = {}, response_status = {})
      if options.class == Hash
         options.merge!( :layout => 'spakit' ) if ( self.params[:layout].to_s == 'spakit' && !options.include?(:layout) )
      elsif options.class == String
        options = options + '?layout=spakit' if ( self.params[:layout].to_s == 'spakit' && !options.include?('layout=') )
      end
      
      rails_redirect_to(options, response_status)
    end
    
    # deprecated_status is for rspec compatible
    # http://rubyforge.org/pipermail/rspec-users/2007-November/004780.html
    def render(options = nil,deprecated_status=nil, &block) #:doc:
      options.merge!( :layout => 'spakit' ) if ( options.class == Hash && !options.include?(:layout) && self.params[:layout].to_s == 'spakit' )
      options = { :layout => 'spakit' } if ( !options && self.params[:layout].to_s == 'spakit' ) #rails default
      
      rails_render(options, &block)
    end
  end
  
end
