module Shoppe
  class AttachmentsController < Shoppe::ApplicationController
    before_filter :login_required
    def destroy
      @attachment = Shoppe::Attachment.find_by!(token: params[:id])
      @attachment.destroy
      respond_to do |wants|
        wants.html { redirect_to request.referer, notice: t('shoppe.attachments.remove_notice') }
        wants.json { render status: 'complete' }
      end
    end
  end
end
