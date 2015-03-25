# -*- coding: utf-8 -*-
module GenericWorkHelper
  def display_title(gf)
    gf.to_s
  end

  def present_terms(presenter, terms=:all, &block)
    terms = presenter.terms if terms == :all
    Sufia::PresenterRenderer.new(presenter, self).fields(terms, &block)
  end

  def render_download_icon title = nil
    if title.nil?
      link_to download_image_tag, sufia.download_path(@generic_work), { target: "_blank", title: "Download the document", id: "file_download", data: { label: @generic_work.id } }
    else
      link_to (download_image_tag(title) + title), sufia.download_path(@generic_work), { target: "_blank", title: title, id: "file_download", data: { label: @generic_work.id } }
    end
  end

  def render_download_link text = nil
    link_to (text || "Download"), sufia.download_path(@generic_work), { id: "file_download", target: "_new", data: { label: @generic_work.id } }
  end

  def render_collection_list gf
    unless gf.collections.empty?
      ("Is part of: " + gf.collections.map { |c| link_to(c.title, collections.collection_path(c)) }.join(", ")).html_safe
    end
  end

  def display_multiple value
    auto_link(Array(value).join(" | "))
  end

  private

  def download_image_tag title = nil
    if title.nil?
      image_tag "default.png", { alt: "No preview available", class: "img-responsive" }
    else
      image_tag sufia.download_path(@generic_file, file: 'thumbnail'), { class: "img-responsive", alt: "#{title} of #{@generic_work.title.first}" }
    end
  end

  def render_visibility_badge
    if can? :edit, @generic_work
      render_visibility_link @generic_work
    else
      render_visibility_label @generic_work
    end
  end

end
