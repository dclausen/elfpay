defmodule ElfPay.Repo do
  use Ecto.Repo,
    otp_app: :elf_pay,
    adapter: Ecto.Adapters.SQLite3
end
