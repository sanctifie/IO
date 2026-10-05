namespace IoDotnet.Web.Services;

/// <summary>Logique métier minuscule, mais testée : c'est elle que le pipeline vérifie à chaque commit.</summary>
public static class Greeting
{
    public static string Title(string? environment) =>
        string.IsNullOrWhiteSpace(environment) || environment == "Production"
            ? "Get started right away with Azure DevOps"
            : $"Get started right away with Azure DevOps ({environment})";
}
