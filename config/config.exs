import Config

config :elf_pay, ecto_repos: [ElfPay.Repo]
config :elf_pay, ElfPay.Repo, pool: Ecto.Adapters.SQL.Sandbox, database: "elf_pay.db", log: false
# config :elf_pay, ElfPay.Repo, database: "elf_pay.db", log: false
