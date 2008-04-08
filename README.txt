Author:: Wen-Tien Chang(mailto:ihower@handlino.com), hlb(mailto:hlb@handlino.com)
Copyright:: Copyright (c) 2007 Handlino Inc.
License:: Distributed under the New BSD License

== Description ==
Spakit is a plugin that makes it very easy to turn your Rails App
Into a "single page application" (SPA).

To enable SPA, simply install the plug-in, create a spakit layout and use Spakit helper.
Don't need modify any model/controller code... ;)

Spakit will send xhr request(i.e. prototype's Ajax.Updater ) with ?layout=spakit, 
and controller return HTML with spakit layout. Note that spakit_form_for not support file upload submit.

By the way, Message plugin is another SPA plugin,using different approach.

== Requirements
 * Rails 2.0.2

== Install ==
 * gem install spakit
 * cd /your_app/vendor/plugin/
 * gem unpack spakit
 
== Usage ==

For now, Spakit provide three helper:

 * spakit_link_to, just like remote_link_to
 * spakit_form_for, just like form_for, but you must specify :url
 * spakit_form_tag, just like form_tag

by default spakit will replace HTML element called #content.

== Layout code example ==
You should write flash message here because we often place that in application layout.

# /view/layouts/spakit.rhtml

<p><%= flash[:notice] %></p>
<%= yield %>

== History Bookmarks ==

We recommend Really Simple History(RSH) library to handle browser forward/back.

Example code:

# environment.rb

module SpakitHelper
  @@spa_options = {
    :update => 'content-region',
    :loading => 'SPA.loading',
    :complete => 'SPA.complete'
  }
end

# application.js
# We use jquery syntax, you can use prototype to define your function.

var $j = jQuery.noConflict();

(function($) {
    SPA = {
        currentHash: null,
        currentLocation: null,
        init: function() {
            if ( $('#waiting-message').length == 0 ) {
                $('<div id="waiting-message"><img src="/images/ajax-loader.gif"></div>').appendTo('#bd');
                $('#waiting-message').hide();
            }
        },
        loading: function() {
            this.init();
            $('#waiting-message').show();
        },
        hide: function() {
            $('#waiting-message').hide();
        },
        historyChange: function(newLocation, historyData, isFresh) {
            if (isFresh == null) {
                if (historyStorage.hasKey(newLocation)) {
                    if (newLocation == "start") {
                        newLocation = location.pathname;
                    }

                    $.ajax({
                        type: "GET",
                        url: newLocation,
                        data: { layout: "spakit" },
                        beforeSend: function(){ SPA.loading(); },
                        complete: function(res, status){
                            if ( status == "success" || status == "notmodified" ) {
                                $('#content-region').html(res.responseText);
                            }
                            SPA.hide();
                        }
                    });
                }
            } else {
                /* new data */
                dhtmlHistory.add(newLocation, historyData);
            }
        },
        complete: function(newLocation) {
            this.historyChange(newLocation, "", true);
            this.hide();
        }
    };
    
    SPA.currentHash = window.location.hash;
    if (SPA.currentHash.length) {
        if (SPA.currentHash.charAt(0) == '#' && SPA.currentHash.charAt(1) == '/') {
            SPA.currentLocation = SPA.currentHash.slice(1);
        }
    }

    $(document).ready(function(){
        dhtmlHistory.initialize();
        if (SPA.currentLocation) {
            if (SPA.currentLocation != '#start') {
                window.location.href = SPA.currentLocation;
            }
        } else {
            dhtmlHistory.addListener(SPA.historyChange);
            if (dhtmlHistory.isFirstLoad()) {
                dhtmlHistory.add("start", "");
            }
        }
    });

})(jQuery);

window.dhtmlHistory.create({
    toJSON: function(o) {
        return JSON.stringify(o);
    },
    fromJSON: function(s) {
        return JSON.parse(s);
    }
});