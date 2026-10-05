using IoDotnet.Web.Services;
using Xunit;

public class GreetingTests
{
    [Fact]
    public void Title_EnProduction_SansSuffixe() =>
        Assert.Equal("Get started right away with Azure DevOps", Greeting.Title("Production"));

    [Fact]
    public void Title_AutreEnvironnement_AjouteLeNom() =>
        Assert.Equal("Get started right away with Azure DevOps (Staging)", Greeting.Title("Staging"));
}
