-- Fix wallet_transactions CHECK constraints to allow 'credit' type
-- and 'payment_milestone_released' reason for collab payment releases

ALTER TABLE wallet_transactions DROP CONSTRAINT IF EXISTS wallet_transactions_type_check;
ALTER TABLE wallet_transactions ADD CONSTRAINT wallet_transactions_type_check 
  CHECK (type IN ('topup', 'deduct', 'credit'));

ALTER TABLE wallet_transactions DROP CONSTRAINT IF EXISTS wallet_transactions_reason_check;
ALTER TABLE wallet_transactions ADD CONSTRAINT wallet_transactions_reason_check 
  CHECK (reason IN ('wallet_topup', 'collab_fee_deducted', 'refund', 'payment_milestone_released'));
