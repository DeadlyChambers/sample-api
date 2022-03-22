using System.Reflection;
using common;
using Microsoft.AspNetCore.Mvc;

namespace data.Controllers;

[ApiController]
[Route("[controller]")]
public class SystemController : ControllerBase
{
    private readonly ILogger<SystemController> _logger;

    public SystemController(ILogger<SystemController> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Basic System Call
    /// </summary>
    /// <returns></returns>
    public SecureSystemObj Get()
    {
        return new SecureSystemObj(Assembly.GetExecutingAssembly());
    }
}
