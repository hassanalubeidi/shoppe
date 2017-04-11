module Shoppe
  class VariantsController < ApplicationController
    before_filter { @active_nav = :products }
    before_filter { @product = Shoppe::Product.find(params[:product_id]) }
    before_filter { params[:id] && @variant = @product.variants.find(params[:id]) }
    skip_before_action :verify_authenticity_token

    def index
      @variants = @product.variants.ordered
    end

    def show
      render json: @variant
    end

    def new
      @variant = @product.variants.build
      render action: 'form'
    end

    def create
      @variant = @product.variants.build(safe_params)
      @variant.attachments.build(decode_base64)
        if @variant.save
          render json: @product.variants.last
        else
          render json: @varaint.errors, status: :unprocessable_entity
        end
    end

    def edit
      render action: 'form'
    end

    def update
      if @variant.update(safe_params)
        redirect_to edit_product_variant_path(@product, @variant), notice: t('shoppe.variants.update_notice')
      else
        render action: 'form'
      end
    end

    def destroy
      @variant.destroy
      redirect_to [@product, :variants], notice: t('shoppe.variants.destroy_notice')
    end

    private

    def safe_params
      file_params = [:file, :parent_id, :role, :parent_type, file: []]
      params[:product].permit(:name, :permalink, :sku, :default_image_file, :price, :cost_price, :tax_rate_id, :weight, :stock_control, :active, :default, product_attributes_array: [:key, :value, :searchable, :public, :customizable], attachments: [default_image: file_params, data_sheet: file_params, extra: file_params])
    end

    def decode_base64
      # decode base64 string
      Rails.logger.info 'decoding base64 file'
      decoded_data = Base64.decode64(params["product"]["attachments"]["default_image"]["base64"])
      # create 'file' understandable by Paperclip
      data = StringIO.new(decoded_data)
      data.class_eval do
        attr_accessor :content_type, :original_filename
      end

      # set file properties
      data.content_type = params["product"]["attachments"]["default_image"]["filetype"]
      data.original_filename = params["product"]["attachments"]["default_image"]["filename"]

      # return data to be used as the attachment file (paperclip)
      data
    end
  end
end
