# == Schema Information
#
# Table name: farms
#
#  id         :integer          not null, primary key
#  name       :string
#  address    :string
#  zipcode    :string
#  city       :string
#  owner_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FarmsController < ApplicationController
  load_and_authorize_resource

  before_action :set_farm, only: [:show, :edit, :update, :destroy]

  # GET /farms/list
  # GET /farms.json
  def list
    if current_user.status!='admin'
      redirect_to root_path
    end
  end

  # GET /farms
  # GET /farms.json
  def index
    if params.has_key?(:from_user) && params[:from_user] == true && signed_in?
      @farms = current_user.farms
      @from_user = true
    else
      @from_user = false

      if params.has_key?(:location)
        @farms = Farm.where(:zipcode => params[:location])
      else
        @farms = Farm.all
      end
    end
  end

  # GET /farms/1
  # GET /farms/1.json
  def show
  end

  # GET /farms/new
  def new
    @farm = Farm.new
  end

  # GET /farms/1/edit
  def edit
  end

  # POST /farms
  # POST /farms.json
  def create
    @farm = Farm.new(farm_params)
    @farm.owner_id=current_user.id

    respond_to do |format|
      if @farm.save
        format.html { redirect_to @farm, notice: 'Farm was successfully created.' }
        format.json { render :show, status: :created, location: @farm }
      else
        format.html { render :new }
        format.json { render json: @farm.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /farms/1
  # PATCH/PUT /farms/1.json
  def update
    respond_to do |format|
      if @farm.update(farm_params)
        format.html { redirect_to @farm, notice: 'Farm was successfully updated.' }
        format.json { render :show, status: :ok, location: @farm }
      else
        format.html { render :edit }
        format.json { render json: @farm.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /farms/1
  # DELETE /farms/1.json
  def destroy
    @farm.products.each do |product|
      product.destroy
    end
    @farm.destroy
    respond_to do |format|
      format.html { redirect_to farms_url, notice: 'Farm was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_farm
    @farm = Farm.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def farm_params
    params.require(:farm).permit(:name, :address, :zipcode, :city, :description, :owner_id)
  end
end
