# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module Wikis
  class RelationPageLinksController < ApplicationController
    include OpTurbo::ComponentStream

    before_action :authorize

    def create
      # TODO: Wikis::PageLinks::CreateService
      page_link = RelationPageLink.create!(**relation_page_link_params)

      path = derive_path_from_linkable(page_link.linkable)
      return redirect_to path, status: :see_other if path

      head :no_content
    end

    def destroy
      # TODO: Wikis::PageLinks::DeleteService
      page_link = find_page_link
      page_link.destroy!

      path = derive_path_from_linkable(page_link.linkable)
      return redirect_to path, status: :see_other if path

      head :no_content
    end

    def confirm_delete_dialog
      page_link = find_page_link
      respond_with_dialog(DeleteRelationPageLinkConfirmationDialog.new(page_link:))
    end

    def link_existing_dialog
      linkable = WorkPackage.visible.find(params.expect(:work_package))
      provider = Provider.visible.find(params.expect(:provider))
      respond_with_dialog Wikis::LinkExistingWikiPageDialog.new(linkable:, provider:)
    end

    private

    def find_page_link
      RelationPageLink.find(params.expect(:id))
    end

    def relation_page_link_params
      params.expect(wikis_relation_page_link: %i[identifier provider_id linkable_type linkable_id])
            .merge(author: current_user)
    end

    def derive_path_from_linkable(linkable)
      case linkable
      when WorkPackage
        project_work_package_wikis_tab_index_path(work_package_id: linkable.id, project_id: linkable.project_id)
      end
    end
  end
end
