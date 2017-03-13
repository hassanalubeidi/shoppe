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
      respond_to do |format|
        if @variant.save
          format.html { redirect_to [@product, :variants], notice: t('shoppe.variants.create_notice') }
          format.json { render json: @varaint }
        else
          format.html { render action: 'form' }
          format.json { render json: @varaint.errors, status: :unprocessable_entity }
        end
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
      params[:product].permit(:name, :permalink, :sku, :default_image_file, :price, :cost_price, :tax_rate_id, :weight, :stock_control, :active, :default, product_attributes_array: [:key, :value, :searchable, :public, :customizable])
    end
  end
end
