using System.Reflection;
namespace common;

/// <summary>
/// Clean way of outputting the Assembly Attributes
/// </summary>
internal static class AssemblyInfo
{
    public static string Product { get { return GetExecutingAssemblyAttribute<AssemblyProductAttribute>(a => a.Product); } }
    public static string Company { get { return GetExecutingAssemblyAttribute<AssemblyCompanyAttribute>(a => a.Company); } }
    public static string Description { get { return GetExecutingAssemblyAttribute<AssemblyDescriptionAttribute>(a => a.Description); } }
    public static string Configuration { get { return GetExecutingAssemblyAttribute<AssemblyConfigurationAttribute>(a => a.Configuration); } }
    public static string Version { get { return GetExecutingAssemblyAttribute<AssemblyInformationalVersionAttribute>(a => a.InformationalVersion); } }

    private static string GetExecutingAssemblyAttribute<T>(Func<T, string> value) where T : Attribute
    {
        T attribute = (T)Attribute.GetCustomAttribute(Assembly.GetExecutingAssembly(), typeof(T));
        return value.Invoke(attribute);
    }
}

/// <summary>
/// Secure System Object will output a bunch of assembly info in order to identify
/// the application and underlying infrastructure
/// </summary>
public class SecureSystemObj : SystemObj
{
    /// <summary>
    /// Create a system object
    /// </summary>
    public SecureSystemObj()
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
            //Allowing Everything to be seen
            Version = AssemblyInfo.Version;
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
    public SystemObj()
    {
        //Not outputting the web server type
        Version = AssemblyInfo.Version.Split('-')[0];
    }

    public static string Product { get { return AssemblyInfo.Product; } }
    //public string Copyright { get { return AssemblyInfo.Copyright; } }
    public static string Company { get { return AssemblyInfo.Company; } }
    public static string Configuration { get { return AssemblyInfo.Configuration; } }
    public static string Description { get { return AssemblyInfo.Description; } }
    public string Version { get; set; }
    public static string  Date { get; } = DateTime.Now.ToString("G");


}
