using System.Net.Http;
using System.Net;
using System;
using Microsoft.AspNetCore.Mvc;
using common;
using System.Text;
using System.Reflection;

namespace system.Controllers
{

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
        
        public SystemModel Get()
        {
            _logger.LogDebug("Entering Get");
                      
              
            return new SystemModel
            {
                Name = "Testing API",
                Version = Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>().Version 
      
            };
        }
    }
}