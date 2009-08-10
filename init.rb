# Load the stickies code
require 'stickies'
# Hook into the Rails system
ActionController::Base.send(:include, Stickies::ControllerActions)
ActionController::Base.send(:include, Stickies::AccessHelpers)
ActionView::Base.send(:include, Stickies::AccessHelpers)
ActionView::Base.send(:include, Stickies::RenderHelpers)