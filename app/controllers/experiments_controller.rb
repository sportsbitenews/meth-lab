class ExperimentsController < ApplicationController

  # GET /experiments
  # GET /experiments.json
  def index
    @headline = simple_experiment(27, 'control', 'exp')
    mark_kpi!('mooo')
    # @test_2 = simple_experiment(23, 'control', 'exp')
    # @test_3 = simple_experiment(23, 'control', 'exp')

    @slots = Lacmus::SlotMachine.experiment_slots
    @pending_experiments = Lacmus::Experiment.all_from(:pending)
    @completed_experiments = Lacmus::Experiment.all_from(:completed)
     respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experiments }
    end
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show
    @experiment = Lacmus::Experiment.new(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json:  }
    end
  end

  def activate
    if (Lacmus::SlotMachine.activate_experiment(params[:id]))
      flash[:success] = ("Experiment is now active! Check your website.")
    else
      flash[:error] = ("Failed to activate experiment. Make sure you have available slots in your pizza.")
    end
    redirect_to root_path
  end

  def delete
    if (Lacmus::SlotMachine.destroy_experiment(params[:list], params[:id].to_i))
      flash[:success] = ("Experiment is now active! Check your website.")
    else
      flash[:error] = ("Failed to activate experiment. Make sure you have available slots in your pizza.")
    end
    redirect_to root_path
  end

  def get_code
  end

  def experiment_data
    @experiment = Lacmus::Experiment.new(params[:id])
    respond_to do |format|

      format.html {
        render :partial => 'experiment_data', :locals => {:experiment => @experiment}
      } # show.html.erb
      # format.json { render json:  }
    end
  end

  # GET /experiments/new
  # GET /experiments/new.json
  def new
    @experiment = Lacmus::Experiment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: {} }
    end
  end

  # GET /experiments/1/edit
  def edit
    @experiment = Lacmus::Experiment.new(params[:id])
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

    @experiment = Lacmus::Experiment.new
    validate_experiment

    if  @experiment.errors.empty?
      experiment_id = Lacmus::SlotMachine.create_experiment(params[:name], params[:description])
      @experiment.errors << "failed to create experiment" unless experiment_id
    end

    respond_to do |format|
      if @experiment.errors.empty?
        format.html { 
            redirect_to get_code_experiment_path(experiment_id), :flash => { :success => 'Slice Created Successfully!' } 
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
    @experiment = Lacmus::Experiment.new(params[:id])
    validate_experiment

    if @experiment.errors.empty?
      # success = Lacmus::SlotMachine.update_experiment(params[:name], params[:description], params[:screenshot_url])
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
    # @experiment = Experiment.new(params[:id])
    Lacmus::SlotMachine.deactivate_experiment(params[:id])
    redirect_to root_path
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.json
  def destroy
    @dashboard = Dashboard.find(params[:id])
    @dashboard.destroy

    respond_to do |format|
      format.html { redirect_to experiments_url }
      format.json { head :no_content }
    end
  end
end
