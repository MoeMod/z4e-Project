#include <amxmodx>
#include <amxmisc>

#define PLUGIN "[Z4E] Map Check"
#define VERSION "1.0"
#define AUTHOR "Xiaobaibai"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public plugin_precache()
{
	new szMap[4];
	get_mapname(szMap, 3)
	if(equali(szMap, "ze_")) // equali比较字符串不区分大小写
		return;
	
	new szPath[64];
	new szConfigDir[64];
	get_configsdir(szConfigDir, charsmax(szConfigDir))
	format(szPath, charsmax(szPath), "%s/plugins-z4e.ini", szConfigDir);
	
	if (!file_exists(szPath))
	{
		set_fail_state("Couldn't Open plugins-z4e.ini!");
		return;
	}
	
	new linedata[1024], iLine;
	new fp = fopen(szPath, "rt");
	while (fp && !feof(fp))
	{
		fgets(fp, linedata, charsmax(linedata));
		replace(linedata, charsmax(linedata), "^n", "");

		if (!('a' <= linedata[0] <= 'z') && !('A' <= linedata[0] <= 'Z'))
			continue;

		for(new i=0;linedata[i];i++)
			if(isspace(linedata[i]))
			{
				linedata[i] = 0;
				break;
			}
		
		pause("ac", linedata);

		iLine++;
	}
	fclose(fp);
	return;
	
}   