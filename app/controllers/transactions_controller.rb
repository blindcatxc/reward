class TransactionsController < ApplicationController

  def create
    tran = Transaction.new(transaction_params)
    if transaction_params[:points].is_a?(Integer) && transaction_params[:points] < 0
      tran.source_transaction = Transaction.where(payer: transaction_params[:payer], redeemed_at: nil)
        .where("points >= #{transaction_params[:points]}")
        .order(timestamp: :asc).find do |t|
          t.balance >= transaction_params[:points].abs
        end

      if tran.source_transaction.nil?
        render status: :unprocessable_entity, json: {
          errors: ["Can not create transction result in negative balance."]
        }
        return
      end
    end
    if tran.save
      render status: 201, json: {}.to_json
    else
      render status: 422, json: { errors: tran.errors.full_messages }.to_json
    end
  end

  def spend
    points = params[:points]
    if !points.is_a?(Integer) || points.to_i <= 0
      return render status: 422, json: { errors: ['Points must be a positive integer'] }.to_json
    end
    redempts = Transaction.spend_points(points.to_i)
    if redempts.empty?
      render status: 422, json: { errors: ['Not enough points'] }.to_json
    else
      render status: 200, json: redempts.map { |t| { payer: t.payer, points: t.points.abs } }.to_json
    end
  end

  def balance
    rel = Transaction.group(:payer).sum(:points)
    serialization = rel.map do |payer, points|
      { payer: payer, points: points.to_i }
    end
    render status: 200, json: serialization.to_json
  end

  private

  def transaction_params
    params.permit(
      :points,
      :payer,
      :timestamp
    )
  end

end