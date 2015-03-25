module Sufia::WorksControllerBehavior
  extend ActiveSupport::Concern
  include Sufia::Breadcrumbs

  included do
    include Hydra::Controller::ControllerBehavior
    include Blacklight::Base
    include Sufia::WorksController::CollectionBehavior

    layout "sufia-one-column"

    self.copy_blacklight_config_from(CatalogController)

    # Catch permission errors
    rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
      if exception.action == :edit
        redirect_to(sufia.url_for({action: 'show'}), alert: "You do not have sufficient privileges to edit this document")
      elsif current_user and current_user.persisted?
        redirect_to root_url, alert: exception.message
      else
        session["user_return_to"] = request.url
        redirect_to new_user_session_url, alert: exception.message
      end
    end

    # actions: audit, index, create, new, edit, show, update,
    #          destroy, permissions, citation, stats
    before_filter :authenticate_user!, except: [:show, :citation, :stats]
    before_filter :has_access?, except: [:show]
    before_filter :build_breadcrumbs, only: [:show, :edit, :stats]
    load_resource only: [:audit]
    load_and_authorize_resource except: [:index, :audit]

    class_attribute :edit_form_class, :presenter_class
    self.edit_form_class = Sufia::Forms::GenericWorkEditForm
    self.presenter_class = Sufia::GenericWorkPresenter
  end

  def show
    query_collection_members
    respond_to do |format|
      format.html {
        @events = @generic_work.events(100)
        @presenter = presenter
        @audit_status = audit_service.human_readable_audit_status
      }
      format.endnote { render text: @generic_work.export_as_endnote }
    end
  end

  protected
  def audit_service
    Sufia::GenericWorkAuditService.new(@generic_work)
  end

  def presenter_class
    Sufia::GenericWorkPresenter
  end

  def presenter
    @presenter ||= presenter_class.new(@generic_work)
  end

end