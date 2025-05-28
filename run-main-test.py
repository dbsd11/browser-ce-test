import os
script_path=os.path.dirname(__file__)
os.chdir(script_path)

from hmdriver2.driver import Driver
from hmdriver2.proto import DeviceInfo, KeyCode, DisplayRotation

def test_app(d: Driver, package_name):
    try:
        from pathlib import Path
        package_path = Path('.').joinpath(package_name.replace('.', '_'))
        output_path = package_path.joinpath("output")
        output_path.mkdir(parents=True, exist_ok=True)

        main_ability = d.get_app_main_ability(package_name)
        d.force_start_app(package_name, main_ability["name"])

        dump_json = d.dump_hierarchy()
        import json
        with open(output_path.joinpath('hierarchy.json'), 'w', encoding='utf-8') as f:
            json.dump(dump_json, f, ensure_ascii=False, indent=2)

        testFileName = "File.txt"
        with open(output_path.joinpath(testFileName), 'w', encoding='utf-8') as f:
            f.writelines(["hello world"])
        rpath = "/data/local/tmp/"
        d.push_file(output_path.joinpath(testFileName), rpath)

        newTestFileName = "NewFile.txt"
        d.pull_file(rpath + '/' + testFileName, output_path.joinpath(newTestFileName))
        # check newTestFileName exist
        assert output_path.joinpath(newTestFileName).exists()

        d.screenshot(output_path.joinpath("startUp.png"))
        assert output_path.joinpath("startUp.png").exists()

        with d.screenrecord.start(output_path.joinpath("runTest.mp4")):
            try:
                import importlib
                test_module = importlib.import_module(package_name.replace('.', '_') + ".test")
                importlib.reload(test_module)
                if hasattr(test_module, 'test'):
                    test_module.test(d)
            except Exception as e:
                print(e)
            import time
            # do somethings
            time.sleep(5)
    except Exception as e:
        print(e)
    finally:
        d.stop_app(package_name)
        current_apps = d.current_app()
        assert [app for app in current_apps if (app and app[0] == package_name)] == []

if __name__ == '__main__':
    d = Driver()
    info: DeviceInfo = d.device_info
    print(info)
    # ouput: DeviceInfo(productName='HUAWEI Mate 60 Pro', model='ALN-AL00', sdkVersion='12', sysVersion='ALN-AL00 5.0.0.60(SP12DEVC00E61R4P9log)', cpuAbi='arm64-v8a', wlanIp='172.31.125.111', displaySize=(1260, 2720), displayRotation=<DisplayRotation.ROTATION_0: 0>)

    d.display_size
    d.display_rotation

    d.set_display_rotation(DisplayRotation.ROTATION_180)
    d.set_display_rotation(DisplayRotation.ROTATION_180)

    d.press_key(KeyCode.POWER)

    d.swipe(0.5, 0.8, 0.5, 0.4)

    d.go_back()
    d.go_home()
    d.screen_on()
    d.screen_off()
    d.unlock()
    
    test_app(d, "org.ohosdev.browserce")

    d.close()
    del d
    
    print("test ended")
    os._exit(0)