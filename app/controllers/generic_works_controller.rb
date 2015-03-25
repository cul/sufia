# -*- coding: utf-8 -*-
class GenericWorksController < ApplicationController
  include Sufia::Controller
  include Sufia::WorksControllerBehavior
end