defmodule ExLedger do
  @moduledoc """
  Public API.
  """

  alias ExLedger.Accounts.{
    Account,
    CreateAccount,
    UpdateAccountProperties,
    UpdateAccountStatus
  }

  alias ExLedger.Transactions.{
    ConfirmDeposit,
    ConfirmWithdrawal,
    CreateDeposit,
    CreateWithdrawal,
    FailDeposit,
    FailWithdrawal,
    Transaction,
    UpdateTransactionProperties
  }

  @spec create_account(CreateAccount.params()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def create_account(params), do: CreateAccount.execute(params)

  @spec update_account_status(UpdateAccountStatus.params()) ::
          {:ok, Account.t()} | {:error, Ecto.Changeset.t()}
  def update_account_status(params), do: UpdateAccountStatus.execute(params)

  @spec update_account_properties(UpdateAccountProperties.params()) ::
          {:ok, Account.t()} | {:error, :transaction_not_found | Ecto.Changeset.t()}
  def update_account_properties(params), do: UpdateAccountProperties.execute(params)

  @spec create_deposit(CreateDeposit.params()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def create_deposit(params), do: CreateDeposit.execute(params)

  @spec confirm_deposit(ConfirmDeposit.params()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def confirm_deposit(params), do: ConfirmDeposit.execute(params)

  @spec fail_deposit(FailDeposit.params()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def fail_deposit(params), do: FailDeposit.execute(params)

  @spec create_withdrawal(CreateWithdrawal.params()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def create_withdrawal(params), do: CreateWithdrawal.execute(params)

  @spec confirm_withdrawal(ConfirmWithdrawal.params()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def confirm_withdrawal(params), do: ConfirmWithdrawal.execute(params)

  @spec fail_withdrawal(FailWithdrawal.params()) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def fail_withdrawal(params), do: FailWithdrawal.execute(params)

  @spec update_transaction_properties(UpdateTransactionProperties.params()) ::
          {:ok, Transaction.t()} | {:error, :transaction_not_found | Ecto.Changeset.t()}
  def update_transaction_properties(params), do: UpdateTransactionProperties.execute(params)
end
