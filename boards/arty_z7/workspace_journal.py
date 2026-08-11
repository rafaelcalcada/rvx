# 2026-08-11T19:48:39.684627300
import vitis

client = vitis.create_client()
client.set_workspace(path="vitis_prj")

platform = client.create_platform_component(name = "platform",hw_design = "$COMPONENT_LOCATION/../../rvx_arty_z7/rvx_arty_z7.xsa",os = "standalone",cpu = "ps7_cortexa9_0",domain_name = "standalone_ps7_cortexa9_0",compiler = "gcc")

comp = client.create_app_component(name="hello_world",platform = "$COMPONENT_LOCATION/../platform/export/platform/platform.xpfm",domain = "standalone_ps7_cortexa9_0",template = "hello_world")

comp = client.get_component(name="hello_world")
status = comp.import_files(from_loc="$COMPONENT_LOCATION/../..", files=["zynq_helloworld.c"], dest_dir_in_cmp = "src", is_skip_copy_sources = False)

platform = client.get_component(name="platform")
status = platform.build()

comp = client.get_component(name="hello_world")
comp.build()

