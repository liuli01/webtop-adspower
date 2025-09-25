import requests
import json
import time
from typing import Optional, Dict, Any, List

class DolphinAntyAPI:
    def __init__(self, base_url: str, api_token: str, timeout: int = 10):
        """
        base_url: 比如 "http://localhost:3001/v1.0"
        api_token: 你在 Dolphin Anty 控制面板获取的 API Token
        """
        self.base_url = base_url.rstrip('/')
        self.api_token = api_token
        self.session = requests.Session()
        self.session.headers.update({
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_token}"
        })
        self.timeout = timeout

    def _url(self, path: str) -> str:
        return f"{self.base_url}{path}"

    def _get(self, path: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        resp = self.session.get(self._url(path), params=params, timeout=self.timeout)
        resp.raise_for_status()
        return resp.json()

    def _post(self, path: str, body: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        data = json.dumps(body) if body is not None else None
        resp = self.session.post(self._url(path), data=data, timeout=self.timeout)
        resp.raise_for_status()
        return resp.json()

    # ————— 基础 API 接口 —————

    def list_profiles(self) -> Dict[str, Any]:
        """ 获取 profile 列表 """
        return self._get("/browser_profiles")

    def get_profile(self, profile_id: str) -> Dict[str, Any]:
        """ 获取某一个 profile 的详细信息 """
        return self._get(f"/browser_profiles/{profile_id}")

    def create_profile(self, profile_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        创建一个 profile。
        profile_data 的字段结构请参考官方文档。  
        例如 name, tags, platform, browserType, useragent, webrtc, webgl 等。
        """
        return self._post("/browser_profiles", body=profile_data)

    def delete_profile(self, profile_id: str) -> Dict[str, Any]:
        """ 删除一个 profile """
        return self._post(f"/browser_profiles/{profile_id}/stop", None)  # 注意：有些 API 删除是 POST，有些可能是 DELETE，需看文档

    # ————— 启动 / 停止 profile，用于自动化 —————

    def start_profile(self, profile_id: str, automation: bool = True, headless: bool = False) -> Dict[str, Any]:
        """
        启动 profile，让它进入可自动化状态（带 DevTools 协议端口等）
        官方文档中：
        GET /browser_profiles/{PROFILE_ID}/start?automation=1 或 ?automation=1&headless=1 :contentReference[oaicite:0]{index=0}
        """
        params = {
            "automation": 1 if automation else 0
        }
        if headless:
            params["headless"] = 1
        return self._get(f"/browser_profiles/{profile_id}/start", params=params)

    def stop_profile(self, profile_id: str) -> Dict[str, Any]:
        """ 停止 profile """
        return self._get(f"/browser_profiles/{profile_id}/stop")

    # 你还可以添加更多方法：更新 profile、导出 cookies、设置代理、导入/导出 profile 等。

if __name__ == "__main__":
    # 示例使用
    BASE = "http://localhost:3001/v1.0"
    API_TOKEN = "你的_api_token"

    api = DolphinAntyAPI(BASE, API_TOKEN)

    # 1. 列出现有 profiles
    resp = api.list_profiles()
    print("Profiles list:", resp)

    # 2. 创建一个 profile（示例 payload，根据文档调整字段）
    new_profile_payload = {
        "name": "TestProfile",
        "tags": ["test", "demo"],
        "platform": "windows",
        "browserType": "anty",
        "mainWebsite": "",
        "useragent": {
            "mode": "manual",
            "value": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        },
        "webrtc": {"mode": "altered", "ipAddress": None},
        "canvas": {"mode": "real"},
        "webgl": {"mode": "real"},
        # … 其他你需要的字段
    }
    create_resp = api.create_profile(new_profile_payload)
    print("Create profile response:", create_resp)
    profile_id = create_resp.get("browserProfileId") or create_resp.get("id")
    if not profile_id:
        raise RuntimeError("无法获取新 profile 的 ID")

    # 3. 启动 profile（带 automation & headless 可选）
    start_resp = api.start_profile(profile_id, automation=True, headless=False)
    print("Start profile response:", start_resp)

    # 启动成功后通常会返回 automation 对象，里面包含 port 和 wsEndpoint 等 :contentReference[oaicite:1]{index=1}
    automation_info = start_resp.get("automation")
    if automation_info:
        print("Automation info:", automation_info)
        port = automation_info.get("port")
        ws_endpoint = automation_info.get("wsEndpoint")
        # 你可以用 Selenium / Puppeteer / Playwright 去连接这个运行的浏览器去做自动化操作
        # （在该机器上运行，或能够访问这个 DevTools 协议端点）

    # ... 做你要的自动化操作 ...

    # 4. 停止 profile
    stop_resp = api.stop_profile(profile_id)
    print("Stop profile response:", stop_resp)

    # 5. 删除 profile（或根据实际 API 删除接口做调用）
    # 这里假设 delete 是 POST /browser_profiles/{id}/delete 或 /browser_profiles/{id}/stop 再 delete
    # 你需要查文档确认真实路径。
    # 例如：
    # delete_resp = api.delete_profile(profile_id)
    # print("Delete profile response:", delete_resp)
