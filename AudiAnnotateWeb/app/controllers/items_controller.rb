class ItemsController < ApplicationController
  before_action :connect, only: [:add_annotation_file, :create, :destroy, :edit, :show, :update]
  before_action :set_item, only: [:add_annotation_file, :destroy, :edit, :show, :update]

  # GET /items
  # GET /items.json
  def index
    @items = Item.all
  end

  # GET /items/1
  # GET /items/1.json
  def show
  end

  # GET /items/new
  def new
    @item = Item.new(params[:user_name], params[:repo_name])
  end


  # POST /items
  # POST /items.json
  def create
    @item = Item.new(
      item_params[:user_name], 
      item_params[:repo_name], 
      item_params[:label], 
      item_params[:audio_url], 
      item_params[:duration],
      item_params[:provider_uri],
      item_params[:provider_label],
      item_params[:homepage])

    respond_to do |format|
      if @item.save(session[:github_token])
        format.html { redirect_to item_path(@item.user_name, @item.repo_name, @item.slug), notice: 'Item was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end


  def add_annotation_file
    # @item = Item.new(item_params[:user_name], item_params[:repo_name], item_params[:label])

    annotation_file = AnnotationFile.new(@item.canvases.first, item_params[:layer], item_params[:annotation_file])
    if annotation_file.save(session[:github_token])
      sleep 2 # wait for the build status to update
      redirect_to item_path(@item.user_name, @item.repo_name, @item.slug)
    end
  end    



  # GET /items/1/edit
  def edit
  end


  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.from_file(params[:user_name], params[:repo_name], params[:slug])
      if @github_client
        @pages_site_status = @github_client.pages("#{@item.user_name}/#{@item.repo_name}").status
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:label, :audio_url, :user_name, :repo_name, :duration, :layer, :annotation_file, :provider_uri, :provider_label, :homepage)
    end
end
