import time
from hmdriver2.driver import Driver

def create_dev_center_app(d: Driver, app_name, outer_url):
    d(text="My Apps").click_if_exists()
    d(type="button", text=" New App").click_if_exists()
    d(type="button", text="Create an App").click_if_exists()
    if not d(type="textField", index=0).exists(retries=5):
        return
    d(type="textField", index=0).input_text(app_name)
    d(type="button", text="好的").click_if_exists()
    time.sleep(5)
    if not d(text="Settings").exists(retries=10):
        return
    d(text="Settings").click_if_exists()
    
    d.swipe_ext("up", scale=0.1)
    
    indexUrlField = d(type="textField", text="https://dev-center.puter.com/coming-soon.html")
    if not indexUrlField.exists(retries=3):
        return  
    
    for i in range(2):
        indexUrlField.clear_text()
    indexUrlField.input_text(outer_url)
    d(type="button", text="Save").click_if_exists()
    time.sleep(5)
    d(type="button", text="Back").click_if_exists()
    time.sleep(2)


def delete_dev_center_app(d: Driver, app_name):
    d(text="My Apps").click_if_exists()
    if not d(type="textField").exists(retries=5):
        return
    d(type="textField", index=0).input_text(app_name)
    d(text="My Apps", index=0).click_if_exists()
    time.sleep(2)
    while d(type="checkBox", index=1).exists():
        d(type="checkBox", index=1).click_if_exists()
        d(type="button", text="Delete").click_if_exists()
        if not d(type="button", text="Delete", index=1).exists(retries=5):
            break
        d(type="button", text="Delete", index=1).click_if_exists()
        time.sleep(2)

def test_demo(d: Driver):
    if not d(text="Dev Center").exists(retries=30):
        d(id="navigationButton3").click_if_exists()
    if d(text="Dev Center").exists(retries=30):
        d(text="Dev Center").click_if_exists()
        for i in range(5):
            if d(type="button", text=" New App").exists() or d(type="button", text="Create an App").exists() :
                create_dev_center_app(d, "testapp", "https://www.baidu.com")
                delete_dev_center_app(d, "testapp")
                break
    time.sleep(5)
    
def test_english_teaching_apps(d: Driver):
    if not d(text="Dev Center").exists(retries=30):
        d(id="navigationButton3").click_if_exists()
    
    if d(text="Dev Center").exists(retries=30):
        d(text="Dev Center").click_if_exists()
        
        # 创建英语教学相关的应用
        # 创建主流英语教学应用
        apps = [
            ("Duolingo", "https://www.duolingo.com"),  # 全球最受欢迎的语言学习应用
            ("Cambly", "https://www.cambly.com"),  # 在线英语口语外教平台
            ("ELSA_Speak", "https://elsaspeak.com"),  # AI驱动的英语发音教练
            ("Cake", "https://mycake.me"),  # 基于真实视频的英语学习
            ("Lingokids", "https://www.lingokids.com"),  # 儿童英语学习平台
            ("Memrise", "https://www.memrise.com"),  # 记忆词汇学习平台
            ("Busuu", "https://www.busuu.com"),  # 社交语言学习平台
            ("HelloTalk", "https://www.hellotalk.com"),  # 语言交换社交平台
            ("Rosetta_Stone", "https://www.rosettastone.com"),  # 经典语言学习软件
            ("BBC_Learning", "https://www.bbc.co.uk/learningenglish")  # BBC英语学习资源
        ]
        
        for app_name, url in apps:
            if d(type="button", text=" New App").exists() or d(type="button", text="Create an App").exists():
                create_dev_center_app(d, app_name, url)
                time.sleep(2)
    time.sleep(5)
    
def test(d: Driver):
    test_english_teaching_apps(d)