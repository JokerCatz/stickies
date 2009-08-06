################################################################################
#
# Copyright (C) 2007 pmade inc. (Peter Jones pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
module Stickies
  module RenderHelpers

    ################################################################################
    # Render the stickie messages, returning the resulting HTML , map to jGrowl Options , Options are:
    #
    # +header+ [""] Optional header to prefix the message, this is often helpful for associating messages to each other.
    # +sticky+ [false] When set to true a message will stick to the screen until it is intentionally closed by the user.
    # +glue+ ["after"] Designates whether a jGrowl notification should be appended to the container after all notifications, or whether it should be prepended to the container before all notifications. Options are after or before.
    # +position+ ["top-right"] Designates a class which is applied to the jGrowl container and controls it's position on the screen. By Default there are five options available, top-left, top-right, bottom-left, bottom-right, center. This must be changed in the defaults before the startup method is called.
    # +theme+ ["default"] A CSS class designating custom styling for this particular message.
    # +corners+ ["10"px] If the corners jQuery plugin is include this option specifies the curvature radius to be used for the notifications as they are created.
    # +check+ ["1000"] The frequency that jGrowl should check for messages to be scrubbed from the screen.
    # +life+ ["3000"] The lifespan of a non-sticky message on the screen.
    # +speed+ ["normal"] The animation speed used to open or close a notification.
    # +easing+ ["swing"] The easing method to be used with the animation for opening and closing a notification.
    # +closer+ [true] Whether or not the close-all button should be used when more then one notification appears on the screen. Optionally this property can be set to a function which will be used as a callback when the close all button is clicked.
    # +closeTemplate+ [&times;] This content is used for the individual notification close links that are added to the corner of a notification.
    # +closerTemplate+ [<div>"[ close all ]"</div>] This content is used for the close-all link that is added to the bottom of a jGrowl container when it contains more than one notification.
    # +log+ [function(e,m,o) {""}] Callback to be used before anything is done with the notification. This is intended to be used if the user would like to have some type of logging mechanism for all notifications passed to jGrowl. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +beforeOpen+ [function(e,m,o) {""}] Callback to be used before a new notification is opened. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +open+ [function(e,m,o) {""} 	Callback to be used when a new notification is opened. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +beforeClose+ [function(e,m,o) {""}] Callback to be used before a new notification is closed. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +close+ [function(e,m,o) {""}] Callback to be used when a new notification is closed. This callback receives the notification's DOM context, the notifications message and it's option object.
    # +animateOpen+ [{ "opacity": 'show' }] The animation properties to use when opening a new notification (default to fadeOut).
    # +animateClose+ [{ "opacity": 'hide' }] The animation properties to use when closing a new notification (defaults to fadeIn).
    # +debug_mode+ [false] debug mode for firebug
    ################################################################################

    def render_stickies (options={})
      configuration = {
        :key            => :stickies,
        :link_html      => {},
      }.update(options)

      #init
      sub_html = ""
      html = ""
      Stickies::Messages.fetch(session, configuration[:key]) do |messages|
        sub_html << render_stickies_separate(messages, configuration)
        messages.flash
      end

      #package
      if sub_html.length > 0
        html << %Q[
        <script type="text/javascript">
            (function($){
              $(document).ready(function(){
        ]

        #closer
        html << '
                $.jGrowl.defaults.closer = function() {
                  console.log('+ (configuration[:closerTemplate] || "[ close all ]") +', this);
                };
        }' if configuration[:closer] || configuration[:closerTemplate]

        #firebug log
        html << %Q[
                $.jGrowl.defaults.log = function(e,m,o) {
                  $("#logs").append("<div><strong>#" + $(e).attr('id') + "</strong> <em>" + (new Date()).getTime() + "</em>: " + m + " (" + o.theme + ")</div>")
                }
        ] if configuration[:debug_mode]

        html << sub_html

        #end
        html << %Q[
              });
            })(jQuery);
        </script>]
      end
      return html
    end

    ################################################################################
    # Helper method to render each stickie message as a separate div.
    def render_stickies_separate (messages, options)
      html = ''
      sub_html = '' # to fix hash end
      messages.each do |m|
        #jGrowl start
				html << '$.jGrowl("' + m.message.gsub(/\\/, '\&\&').gsub(/'/, "''")  + '", {'
        sub_html << "header: \"" + options[:header] + "\"," if options[:header]
        sub_html << "sticky: " + options[:sticky] + "," if options[:sticky] != nil
        sub_html << "glue: \"" + options[:glue] + "\"," if options[:glue]
        sub_html << "position: \"" + options[:position] + "\"," if options[:position]
        #####
        sub_html << "theme: \"" + (options[:theme] || m.level.to_s ) + "\","
        sub_html << "corners: \"" + options[:corners] + "px\"," if options[:corners]
        sub_html << "check: " + options[:check] + "," if options[:check]
        sub_html << "life: " + options[:life] + "," if options[:life]
        sub_html << "speed: \"" + options[:speed] + "\"," if options[:speed]
        sub_html << "easing: \"" + options[:easing] + "\"," if options[:easing]
        sub_html << "closer:" + options[:closer] + "," if options[:closer] != nil
        sub_html << "closeTemplate: \"" + options[:closeTemplate] + "\"," if options[:closeTemplate]
          #finction
        sub_html << 'log: function(e,m,o) {' + options[:log] + '},' if options[:log]
				sub_html << 'beforeOpen: function(e,m,o) {' + options[:beforeOpen] + '},' if options[:beforeOpen]
				sub_html << 'open: function(e,m,o) {' + options[:open] + '},' if options[:open]
				sub_html << 'beforeClose: function(e,m,o) {' + options[:beforeClose] + '},' if options[:beforeClose]
				sub_html << 'close: function(e,m,o) {' + options[:close] + '},' if options[:close]
          #anime
        sub_html << 'animateOpen: function(e,m,o) {' + options[:animateOpen] + '},' if options[:animateOpen]
        sub_html << 'animateClose: function(e,m,o) {' + options[:animateClose] + '},' if options[:animateClose]
          #merge sub_html
        html << sub_html[0..(sub_html.length - 2)] if sub_html.length > 0
        #jGrowl end
				html << '});'
      end
      return html
    end

  end
end
