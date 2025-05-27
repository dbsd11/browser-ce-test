import time
from hmdriver2.driver import Driver

def test(d: Driver):
    if not d(text="Dev Center").exists(retries=6, wait_time=5):
        d(id="navigationButton3").click()
    if d(text="Dev Center").exists(retries=6, wait_time=5):
        d(text="Dev Center").click()
        
    time.sleep(5)