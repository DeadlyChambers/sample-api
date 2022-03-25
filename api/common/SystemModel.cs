using System.Reflection;
namespace common;



/// <summary>
/// Secure System Object will output a bunch of assembly info in order to identify
/// the application and underlying infrastructure
/// </summary>
public class SecureSystemObj : SystemObj
{
    /// <summary>
    /// Create a system object
    /// </summary>
    public SecureSystemObj(Assembly currentAssembly):base(currentAssembly)
    {
        try
        {
            Address = System.Environment.MachineName + " || ";
            Address = System.Environment.GetEnvironmentVariable("COMPUTERNAME") + " || ";
        }
        catch (Exception e)
        {
            //skip it
        }
        try
        {
            var ipaddress = System.Net.Dns.GetHostAddresses(ComputerName);
            foreach (var ip in ipaddress)
            {
                Address += $"{ip} || ";
            }
        }
        catch (Exception e)
        {
            //skip it
        }
    }
    public string Address { get; }
    public string ComputerName { get;  } = System.Net.Dns.GetHostName();
}

/// <summary>
/// Simple System object that simply outputs the version
/// </summary>
public class SystemObj
{
    private readonly Assembly _currentAssembly;
    public SystemObj(Assembly currentAssembly)
    {
        _currentAssembly=currentAssembly;
        //Not outputting the web server type
        Version = _version.Split('-')[0];
    }

    public string Product { get { return _product; } }
    //public string Copyright { get { return AssemblyInfo.Copyright; } }
    public  string Company { get { return _company; } }
    public  string Configuration { get { return _configuration; } }
    public  string Description { get { return _description; } }
    public string Version { get; set; }
    public  string  Date { get; } = DateTime.Now.ToString("G");


    private string _product { get { return _currentAssembly.GetCustomAttribute<AssemblyProductAttribute>()?.Product ?? ""; } }
    private string _company { get { return _currentAssembly.GetCustomAttribute<AssemblyCompanyAttribute>()?.Company ?? ""; } }
    private string _description { get { return _currentAssembly.GetCustomAttribute<AssemblyDescriptionAttribute>()?.Description ?? ""; } }
    private string _configuration { get { return _currentAssembly.GetCustomAttribute<AssemblyConfigurationAttribute>()?.Configuration ?? ""; } }
    private string _version { get { return _currentAssembly.GetCustomAttribute<AssemblyInformationalVersionAttribute>()?.InformationalVersion ?? ""; } }
}
