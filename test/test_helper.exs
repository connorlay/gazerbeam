ExUnit.start(capture_log: true)
Ecto.Adapters.SQL.Sandbox.mode(Gazerbeam.Repo, :manual)
Mox.defmock(Gazerbeam.Client.GitHubMock, for: Gazerbeam.Client)
