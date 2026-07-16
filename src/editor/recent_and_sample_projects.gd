


extends Node
var recent_projects: = {}
enum PROJECT{NAME, PATH, RECENTMODE}
func validate_recent_projects() -> void :
	var directory: = Directory.new()
	var validated_rp: = []
	for item in recent_projects.list:
		var project_path: String = item[PROJECT.PATH]
		if directory.file_exists(project_path):
			validated_rp.append(item)
		if item.size() < 3:
			if ("/sample_projects/" in project_path) or ("/autosaves/" in project_path):
				item.append(0)
			else:
				item.append(1)
	recent_projects.list = validated_rp
func save_recent_projects() -> void :
	recent_projects.file_type = C.VERSION.RECENT_PROJECTS.SID
	recent_projects.file_version = C.VERSION.RECENT_PROJECTS.INTVALUE
	var path: = OS.get_user_data_dir() + "/recent_projects.json"
	var f: = File.new()
	if not f.open(path, File.WRITE) == OK:
		return
	f.store_string(JSON.print(recent_projects, "\t", false))
	f.close()
func public_update_recent_projects(new_project: Array) -> void :
	var rplist: Array = recent_projects.list
	for i in rplist.size():
		if rplist[i][PROJECT.PATH] == new_project[PROJECT.PATH]:
			rplist.remove(i)
			break
	rplist.push_front(new_project)
	var copy_rplist: = rplist.duplicate(true)
	rplist.clear()
	var count: = [0, 0]
	for item in copy_rplist:
		count[item[PROJECT.RECENTMODE]] += 1
		if count[item[PROJECT.RECENTMODE]] <= 6:
			rplist.append(item)
	if rplist.size() > 12:
		rplist.resize(12)
	save_recent_projects()
	E.echo(E.fs_recent_projects_change, {
		E.fs_recent_projects_change.p_recent_projects: rplist, })
func public_load_recent_projects() -> void :
	var loaded_ok: = false
	while true:
		var path: = OS.get_user_data_dir() + "/recent_projects.json"
		var f: = File.new()
		if not f.file_exists(path):
			break
		if not f.open(path, File.READ) == OK:
			break
		var filecontent: = f.get_as_text()
		f.close()
		var parse_result: = JSON.parse(filecontent)
		if not parse_result.error == OK:
			break
		recent_projects = parse_result.result
		if ( not "file_type" in recent_projects) or ( not "file_version" in recent_projects):
			break
		if not recent_projects.file_type == C.VERSION.RECENT_PROJECTS.SID:
			break
		if not recent_projects.file_version == C.VERSION.RECENT_PROJECTS.INTVALUE:
			break
		if not recent_projects.has("list"):
			break
		validate_recent_projects()
		loaded_ok = true
		break
	if not loaded_ok:
		recent_projects = {
			"file_type": C.VERSION.RECENT_PROJECTS.SID, 
			"file_version": C.VERSION.RECENT_PROJECTS.INTVALUE, 
			"list": []
		}
	save_recent_projects()
	E.echo(E.fs_recent_projects_change, {
		E.fs_recent_projects_change.p_recent_projects: recent_projects.list, })
func public_load_sample_projects() -> void :
	var path_sample_projects_dir: = "res://sample_projects"
	var dir: = Directory.new()
	var _err: = 0
	var files: = []
	_err += dir.change_dir(path_sample_projects_dir)
	_err += dir.list_dir_begin(true, true)
	while true:
		var next: = dir.get_next()
		if next == "":
			break
		if not dir.current_is_dir():
			if next.ends_with(".vcb"):
				files.append(next)
	dir.list_dir_end()
	var samplist: = []
	samplist.resize(files.size())
	for i in samplist.size():
		var projname: String = files[i]
		var projpath: = path_sample_projects_dir + "/" + projname
		projname = projname.right(3).left(projname.length() - (3 + 4))
		projname = projname.capitalize()
		samplist[i] = [projname, projpath]
	E.echo(E.fs_sample_projects_change, {
		E.fs_sample_projects_change.p_sample_projects: samplist, })
