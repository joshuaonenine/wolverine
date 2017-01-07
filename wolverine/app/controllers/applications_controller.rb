require 'csv'
class ApplicationsController < ApplicationController

  @@application_types = {
    '1' => '',
  }

  @@app_types = {
    '1' => '月額固定',
    '2' => '完全成功報酬型',
    '3' => '月額固定＋成功報酬型',
    '4' => '成功報酬フィー',
    '5' => 'ハイクラス・エグゼクティブのみ成功報酬'
  }

  @@staff_names = StaffName.all()
  @@content_names = ContentName.all()

  @@listed = {
    '1' => '未上場',
    '2' => '東証1部',
    '3' => '東証2部',
    '4' => '新興市場',
    '5' => 'その他上場'
  }

  @@app_categories = {
    '1' => '会社',
    '2' => '復活',
    '3' => '商品'
  }

  @@app_sub_categories = {
    '1' => '前金',
    '2' => '後金'
  } 

  @@number_of_member = {
    '1' => '1～10名',
    '2' => '11～30名',
    '3' => '31～100名',
    '4' => '101～300名',
    '5' => '301～1000名',
    '6' => '1001～3000名',
    '7' => '3001～10000名',
    '8' => '10001名以上'
  }

  @@contracts = {
    '1' => '入社日が【納品日】',
    '2' => '入社日の1ヶ月後が【納品日】'
  }

  def index
    @q = Application.search(params[:q])
    @applications = @q.result(distinct: true)
    @app_types = @@app_types
    @staff_names = @@staff_names
  end

  def show
    @application = Application.joins(:contents).find_by(id: params[:id])
    respond_to do |format|
      format.html
      format.xlsx
      format.pdf do
        pdf = render_to_string pdf: "#{params[:id]}.pdf",
        template: "applications/show.pdf.erb",
        encoding: "UTF-8",
        orientation: 'Landscape',
        layout: "pdf.html"
        send_data(pdf)
      end

      format.csv do
        send_data render_to_string, filename: "#{params[:id]}.csv", type: :csv
      end
    end
  end

  def search
    @q = Application.search(params[:q])
    @applications = @q.result(distinct: true).page(params[:page]).per(4).includes(:contents)
    @app_types = @@app_types
    @staff_names = @@staff_names
    @staff_hash = {}
    @staff_names.each do |staff|
      @staff_hash[staff.staff_code] = staff.staff_name
    end
  end

  def new
    @app_types = @@application_types
    @staff_names = @@staff_names
  end

  def edit
    @params = params
    @app = Application.joins(:contents).find_by(id: params[:id])
    @app_types = @@application_types
    @staff_names = @@staff_names
  end

  def edit_applic
    @params = params
    set_list
  end

  def edit_app
    @params = params
    @app = Application.joins(:contents).find_by(id: params[:q][:id])
    set_list
    render "edit_applic"
  end

  def complete
    @params = params
    @application = Application.new(save_applic_params(@params))
    @application.save

    save_contents(@params, @application.id) if params[:contents]

    if @params[:q][:draft] == "0"
       render "preview"
    else 
       render "save_draft"
    end

  end

  def copy
    @params = params
    @app = Application.joins(:contents).find_by(id: params[:id])
    @app_types = @@application_types
    @staff_names = @@staff_names
    render "edit"
  end

  def copy_app
    @params = params
    @app = Application.joins(:contents).find_by(id: params[:q][:id])
    set_list
    render "edit_applic"
  end

  def upload
  end

  def update_app	
    @params = params
    @application = Application.find(params[:q][:id])
    @application.update(save_applic_params(@params))

    update_contents(@params, @application.id) if params[:contents]

    if @params[:q][:draft] == "0"
      render "preview"
    else
      render "save_draft"
    end

  end

  def import
    @rows = []
    open(params[:csv_file].path, 'r:utf-8') do |f|
      csv = CSV.new(f, encoding: 'utf-8', :headers => :first_row)
      csv.each do |row|
        @rows = row.fields
      end
    end
  end

  private
    def save_applic_params(p)
      @two_keys = ['company_postal_code', 'billing_postal_code']
      @two_keys.each do |key|
        p[:q][key] = p[:q][key + '1'] + "-" + p[:q][key + '2'] if p[:q][key + '1'] && p[:q][key + '2']
        p[:q][key] = "" if p[:q][key] == "-"
        
        p.delete(key + "1")
        p.delete(key + "2")
      end

      @three_keys = ['phone', 'fax', 'billing_phone', 'billing_fax']
      @three_keys.each do |key|
        p[:q][key] = p[:q][key + '1'] + "-" + p[:q][key + '2'] + "-" + p[:q][key + '3'] if p[:q][key + '1'] && p[:q][key + '2'] && p[:q][key + '3']
        p[:q][key] = "" if p[:q][key] == "--"
        
        p.delete(key + "1")
        p.delete(key + "2")
        p.delete(key + "3")
      end

      p.require(:q).permit(:draft, :inhouse, :application_type, :applic_category, :applic_sub_category , :cid, :account_limit, 
        :company_name, :company_name_kana, :company_postal_code , :company_address, :company_address_kana, :phone, :fax, 
        :supervisor, :supervisor_title, :supervisor_kana, :staff, :staff_title, :staff_kana, :number_of_member, :listed, 
        :rule_deadline, :rule_payment_month, :rule_payment_day, :settling_month , :fee_rates1, :fee_rates2, :fee_rates3, 
        :minimum_fee, :repayment_rule_within, :repayment_rule_within_percentage, :repayment_rule_from , :repayment_rule_to, 
        :repayment_rule_percentage, :billing_name, :billing_name_kana, :billing_postal_code , :billing_address, :billing_address_kana, 
        :billing_phone, :billing_fax, :billing_supervisor, :billing_supervisor_title , :billing_supervisor_kana, :billing_staff, 
        :billing_staff_title , :billing_staff_kana, :billing_rule_deadline, :billing_rule_payment_month, :billing_rule_payment_day, 
        :sales_name, :location_name, :update_date)
    end

    def save_contents(p, appid)
      set_content_params(p, appid)

      save_content_params(p).each do |cp|
        content = Content.new(cp)
        content.save
      end
    end

    def update_contents(p, appid)
      set_content_params(p, appid)

      @contents = Content.where("application_id = ?", appid)
      @contents.each do |content|
        update_content_params(p).each do |cp|
          content.update(cp)
        end
      end
    end

    def set_content_params(p, appid)
      p[:contents].each do |cp|
        cp[:application_id] = appid
        cp[:application_type] = p[:q][:application_type]

        @keys = ['delivery_date', 'billing_date', 'payment_date', 'join_date', 'publish_from_date', 'publish_to_date', 'contract_billing_date', 'contract_payment_date']

        @keys.each do |key|
          if cp[key + '_year'] && cp[key + '_month'] && cp[key + '_day']
            cp[key] = cp[key + '_year'] + "-" + cp[key + '_month'] + "-" + cp[key + '_day']
          end
        end
      end
    end

    def save_content_params(p)
      p.require(:contents).map do |p|
        content_params(ActionController::Parameters.new(p.to_hash))
      end
    end

    def update_content_params(p)
      p.require(:contents).map do |p|
        content_params(ActionController::Parameters.new(p.to_hash))
      end
    end

    def content_params(action_param)
      action_param.permit(:id, :application_id, :application_type, :content_type, :note, :delivery_date, :amount, 
      :billing_date, :payment_date, :update_date, :publish_from_date, :publish_to_date, :number_of_offer, :scout_mail_monthly, :scout_mail_left,
      :recommends_monthly, :recommends_left, :job_info_csv, :high_class, :exective, :completion_rate, :number_done_in_3m, :account_number,
      :fee, :join_date, :contract, :contract_billing_date, :contract_payment_date)
    end

    def set_list
      @app_types = @@application_types
      @staff_names = @@staff_names
      @content_names = @@content_names
      @listed = @@listed
      @app_categories = @@app_categories
      @app_sub_categories = @@app_sub_categories
      @number_of_member = @@number_of_member
      @contracts = @@contracts
    end
end
