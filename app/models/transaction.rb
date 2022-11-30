class Transaction < ApplicationRecord

  has_many :redemptions, class_name: 'Transaction', foreign_key: 'source_transaction_id'
  belongs_to :source_transaction, class_name: 'Transaction', optional: true

  validates :timestamp, :points, :payer, presence: true
  validates :points, numericality: { only_integer: true, other_than: 0 }
  validates :points, numericality: { greater_than: 0 }, if: proc { |t| t.redeemed_at.present? }
  validates :points, numericality: { less_than: 0 }, if: proc { |t| t.source_transaction_id.present? }

  def self.balance
    all.sum(:points)
  end

  def balance
    points + redemptions.sum(:points)
  end

  def spend_points(amount, ts = Time.current)
    redemption = dup
    redemption.points = -amount
    redemption.source_transaction_id = id
    redemption.save!
    update!(redeemed_at: ts) if balance.zero?
    redemption
  end

  def self.spend_points(amount)
    redempts = []
    # check if balance is enough
    return redempts unless amount.is_a?(Integer) && amount > 0
    return redempts if balance < amount

    # first find the earliest transactions that have points
    Transaction.transaction do
      Transaction.where('points > 0')
        .where(redeemed_at: nil)
        .order(timestamp: :asc).each do |tran|

        # if the transaction has enough points to cover the amount
        # then reduce the amount by the points in the transaction
        if tran.balance >= amount
          redempts << tran.spend_points(amount)
          break
        else
          # otherwise, reduce the amount by the balance of the transaction
          # and mark the transaction as redeemed
          amount -= tran.balance
          redempts << tran.spend_points(tran.balance)
        end
      end
    end

    redempts
  end
  
end
