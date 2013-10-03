class ExperimentsController < ApplicationController

  # GET /experiments
  # GET /experiments.json
  def index
    # simple_experiment(2, "default title", "experiment title")
    @slots = Lacmus::SlotMachine.experiment_slot_ids
    @pending_experiments = Lacmus::Experiment.find_all_in_list(:pending)
    @completed_experiments = Lacmus::Experiment.find_all_in_list(:completed)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experiments }
    end
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show
    @experiment = Lacmus::Experiment.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json:  }
    end
  end

  def activate
  	@experiment = Lacmus::Experiment.find(params[:id])
    if @experiment.activate!
      flash[:success] = ("Experiment is now active! Check your website.")
    else
      flash[:error] = ("Failed to activate experiment. Make sure you have available slots.")
    end
    redirect_to root_path
  end

  def reactivate
  	@experiment = Lacmus::Experiment.find(params[:id])
    if @experiment.activate!
      flash[:success] = ("Experiment is now back to active state")
    else
      flash[:error] = ("Failed to reactivate experiment. Make sure you have available slots.")
    end
    redirect_to root_path
  end

  def delete
    if (Lacmus::Experiment.destroy(params[:id]))
      flash[:success] = ("Experiment is now active! Check your website.")
    else
      flash[:error] = ("Failed to activate experiment. Make sure you have available slots.")
    end
    redirect_to root_path
  end

  def get_code
  end

  def experiment_stats
    @experiment = Lacmus::Experiment.find(params[:id])
    respond_to do |format|
      format.html do
        if params[:type].to_s == 'header'
          render :partial => 'experiment_header', :locals => {:experiment => @experiment} and return
        else
          render :partial => 'experiment_stats', :locals => {:experiment => @experiment}
        end
      end
      # format.json { render json:  }
    end
  end

  def timeline_data
  	if Rails.env.development?
  		render json: mock_timeline_data and return
  	end

  	@experiment = Lacmus::Experiment.find(params[:id])
  	kpi 				= params[:kpi]

  	if @experiment.nil? || kpi.nil?
  		render json: {control: [], experiment: []} and return
  	end

  	data = {
  		control: 		@experiment.conversion_timeline_data(kpi, false),
			experiment: @experiment.conversion_timeline_data(kpi, true)
  	}
  	render json: data
  end

  # GET /experiments/new
  # GET /experiments/new.json
  def new
    @experiment = Lacmus::Experiment.new({})

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: {} }
    end
  end

  # GET /experiments/1/edit
  def edit
    @experiment = Lacmus::Experiment.find(params[:id])
  end

  def validate_experiment
    if params[:name].blank? || params[:name].length < 3
      @experiment.errors << "name does not exist or is too short"
    end

    if params[:description].blank? || params[:description].length < 3
      @experiment.errors << "description does not exist or is too short"
    end

    if params[:screenshot].present? && params[:screenshot].length < 3
      @experiment.errors << "screenshot should be a URL does not exist or is too short"
    end
  end

  # POST /experiments
  # POST /experiments.experiment_idson
  def create
    @experiment = Lacmus::Experiment.new({})
    validate_experiment

    if @experiment.errors.empty?
    	@experiment = Lacmus::Experiment.create!(name: params[:name], description: params[:description], screenshot_url: params[:screenshot_url])
      @experiment.errors << "failed to create experiment" unless @experiment
    end

    respond_to do |format|
      if @experiment.errors.empty?
        format.html { 
            redirect_to get_code_experiment_path(@experiment.id), :flash => { :success => 'Slice Created Successfully!' } 
        }
        format.json { render json: @experiment, status: :created, location: @experiment }
      else
        format.html { render action: "new" }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /experiments/1
  # PUT /experiments/1.json
  def update
    @experiment = Lacmus::Experiment.find(params[:id])
    validate_experiment

    if @experiment.errors.empty?
      @experiment.name = params[:name]
      @experiment.description = params[:description]
      @experiment.screenshot_url = params[:screenshot_url]
      unless @experiment.save
        @experiment.errors << "failed to create experiment"
      end
    end

    respond_to do |format|
      if @experiment.errors.empty?
        format.html do
          redirect_to root_path
        end
      else
        format.html { render action: "edit" }
      end
    end
    # respond_to do |format|
    #     format.html { redirect_to @dashboard, notice: 'Dashboard was successfully updated.' }
    #     format.json { head :no_content }
    #   else
    #     format.html { render action: "edit" }
    #     format.json { render json: @dashboard.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  def conclude
    @experiment = Lacmus::Experiment.find(params[:id])
    @experiment.deactivate!

    redirect_to root_path
  end

  def restart
    @experiment = Lacmus::Experiment.find(params[:id])
    @experiment.restart!

    redirect_to experiment_path(params[:id]), :notice => 'Experiment Restarted. Check Start Time to verify...'
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.json
  # def destroy
  #   @dashboard = Dashboard.find(params[:id])
  #   @dashboard.destroy

  #   respond_to do |format|
  #     format.html { redirect_to experiments_url }
  #     format.json { head :no_content }
  #   end
  # end

  private

  def mock_timeline_data(amount = 200)
  	control_stub 		= []
  	experiment_stub = []

  	amount.times do |i|
  		control_stub << rand().round(5)
  		experiment_stub << rand().round(5)
  	end

  	{control: control_stub, experiment: experiment_stub}
  end

end