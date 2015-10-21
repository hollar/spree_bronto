class Spree::Admin::BrontoListsController < Spree::Admin::ResourceController
  before_action :find_stores, only: [:edit, :new]

  def get_lists
    @lists = []
    bronto.read_lists.each do |etl|
      @lists << ["#{etl[:name]}", etl[:id]]
    end
    render partial: "get_lists", layout: false
  end

  private

  attr_reader :bronto, :stores, :site, :store_id, :list_id

  def bronto
    @bronto ||= Bronto.new(bronto_config)
  end

  def site
    @site ||= Spree::Store.find(store_id)
  end

  def store_id
    @store_id ||= params[:store_id] if params.key? :store_id
  end

  def list_id
    @list_id ||= params[:list_id] if params.key? :list_id
  end

  def find_stores
    @stores ||= Spree::Store.all
  end

  def bronto_config
    Spree::BrontoConfiguration.account[site.code]['token']
  end
end
