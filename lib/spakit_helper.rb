module SpakitHelper
  
    @@spa_options = {
      :update => 'content',
      :loading => nil,
      :complete => nil
    }
    
    # api is the same as remote_link_to
    # TODO: omit CSRF auth token if method is get
    def spakit_link_to(name, options = {}, html_options = nil) 
        #abs path will use non-SPA
        return link_to(name,options[:url]) if options[:url].class == String && options[:url].include?('http://')
      
        html_options = { :href => url_for(options[:url]) } unless html_options
        html_options[:href] = url_for(options[:url]) unless (html_options && html_options[:href] )
              
        options.merge!( :method => :get ) unless options[:method]
        options.merge!( :update => @@spa_options[:update] ) if (@@spa_options[:update] && !options[:update])
        options.merge!( :loading => "#{@@spa_options[:loading]}()" ) if (@@spa_options[:loading] && !options[:loading])
        options.merge!( :complete => "#{@@spa_options[:complete]}('#{html_options[:href]}');" ) if (@@spa_options[:complete] && !options[:complete])
        options.merge! ( :with  => "'layout=spakit'" ) unless options[:with]
        
        link_to_remote(name, options, html_options)
    end
      
    # api is the same as remote_remote_for, but you must provide :url
    # spakit_remote_for @event, :url => hash_for_events_path, :html => {...} do |f|
    # is just equal
    # form_remote_for @event, :url => hash_for_events_path.merge(:layout => 'spakit'), :update => 'content', :loading => "SPA.show()",:complete => "SPA.hide()" do |f|
    # TODO: can omit :url
    def spakit_form_for(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      
      target = url_for( options[:url] )
      options.merge!( :update => @@spa_options[:update] ) if (@@spa_options[:update] && !options[:update])
      options.merge!( :loading => "#{@@spa_options[:loading]}()" ) if (@@spa_options[:loading] && !options[:loading])
      options.merge!( :complete => "#{@@spa_options[:complete]}('#{target}');" ) if (@@spa_options[:complete] && !options[:complete])
      
      #can't use options[:with] here because it will force to use Form.serialize
      if options[:url].is_a?(Hash)
        options[:url].merge!( :layout => 'spakit' )
      elsif options[:url].is_a?(String)
        options[:url] = options[:url] + '?layout=spakit' #String
      end
      
      options[:html] = { :action => target } unless options[:html] 
      options[:html].merge!( :action => target ) if ( options[:html] and !options[:html][:action] )
      
      form_remote_for(record_or_name_or_array, *(args << options), &proc) 
    end
    
    def spakit_form_tag( options = {}, &block)  
      target = ( options[:url].is_a?(Hash) ) ? url_for( options[:url] ) : options[:url]
      options.merge!( :update => @@spa_options[:update] ) if (@@spa_options[:update] && !options[:update])
      options.merge!( :loading => "#{@@spa_options[:loading]}()" ) if (@@spa_options[:loading] && !options[:loading])
      options.merge!( :complete => "#{@@spa_options[:complete]}('#{target}');" ) if (@@spa_options[:complete] && !options[:complete])
      
      if options[:url].is_a?(Hash)
        options[:url].merge!( :layout => 'spakit' )
      elsif options[:url].is_a?(String)
        options[:url] = options[:url] + '?layout=spakit' #String
      end
      
      options[:html] = { :action => target } unless options[:html] 
      options[:html].merge!( :action => target ) if ( options[:html] and !options[:html][:action] )
      
      form_remote_tag(options, &block)
    end
end