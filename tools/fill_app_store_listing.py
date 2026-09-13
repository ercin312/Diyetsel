#!/usr/bin/env python3
"""Fill App Store Connect listing fields for e-Diyet (app 6805844542)."""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

import jwt
import requests

APP_ID = "6805844542"
API = "https://api.appstoreconnect.apple.com/v1"
ROOT = Path(__file__).resolve().parents[1]
LISTING = ROOT / "store_listing"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8").strip()


def token() -> str:
    key_id = os.environ["APP_STORE_CONNECT_KEY_ID"].strip()
    issuer = os.environ["APP_STORE_CONNECT_ISSUER_ID"].strip()
    raw = os.environ["APP_STORE_CONNECT_KEY_CONTENT"].strip()
    if "BEGIN PRIVATE KEY" in raw:
        key = raw.replace("\\n", "\n")
    else:
        import base64

        key = base64.b64decode(raw).decode("utf-8")
    now = int(time.time())
    return jwt.encode(
        {"iss": issuer, "iat": now, "exp": now + 18 * 60, "aud": "appstoreconnect-v1"},
        key,
        algorithm="ES256",
        headers={"kid": key_id, "typ": "JWT"},
    )


class Asc:
    def __init__(self, jwt_token: str) -> None:
        self.s = requests.Session()
        self.s.headers.update(
            {
                "Authorization": f"Bearer {jwt_token}",
                "Content-Type": "application/json",
            }
        )

    def get(self, path: str, **params):
        r = self.s.get(f"{API}{path}", params=params or None, timeout=60)
        self._ok(r)
        return r.json()

    def patch(self, path: str, payload: dict):
        r = self.s.patch(f"{API}{path}", data=json.dumps(payload), timeout=60)
        self._ok(r)
        return r.json() if r.content else {}

    def post(self, path: str, payload: dict):
        r = self.s.post(f"{API}{path}", data=json.dumps(payload), timeout=60)
        self._ok(r)
        return r.json() if r.content else {}

    @staticmethod
    def _ok(r: requests.Response) -> None:
        if r.status_code >= 400:
            raise SystemExit(f"ASC {r.status_code} {r.request.method} {r.url}\n{r.text}")


def first_included(doc: dict, typ: str) -> dict | None:
    for item in doc.get("included") or []:
        if item.get("type") == typ:
            return item
    return None


def main() -> int:
    api = Asc(token())
    name = _read(LISTING / "tr" / "name.txt")
    subtitle = _read(LISTING / "tr" / "subtitle.txt")
    privacy = _read(LISTING / "tr" / "privacy_url.txt")
    support = _read(LISTING / "tr" / "support_url.txt")
    marketing = _read(LISTING / "tr" / "marketing_url.txt")
    description = _read(LISTING / "tr" / "description.txt")
    keywords = _read(LISTING / "tr" / "keywords.txt")
    promo = _read(LISTING / "tr" / "promotional_text.txt")
    whats_new = _read(LISTING / "tr" / "release_notes.txt")
    copyright_text = _read(LISTING / "copyright.txt")
    review_notes = _read(LISTING / "review_notes.txt")

    infos = api.get(f"/apps/{APP_ID}/appInfos", include="appInfoLocalizations")
    info = (infos.get("data") or [None])[0]
    if not info:
        raise SystemExit("No appInfo found")
    loc = first_included(infos, "appInfoLocalizations")
    if loc:
        api.patch(
            f"/appInfoLocalizations/{loc['id']}",
            {
                "data": {
                    "type": "appInfoLocalizations",
                    "id": loc["id"],
                    "attributes": {
                        "name": name,
                        "subtitle": subtitle,
                        "privacyPolicyUrl": privacy,
                    },
                }
            },
        )
        print(f"Updated app info localization {loc['id']} ({name} / {subtitle})")
    else:
        print("No appInfoLocalization; skip name/subtitle/privacy URL")

    versions = api.get(
        f"/apps/{APP_ID}/appStoreVersions",
        **{
            "filter[platform]": "IOS",
            "sort": "-createdDate",
            "limit": 10,
            "include": "appStoreVersionLocalizations,appStoreReviewDetail",
        },
    )
    editable_states = {
        "PREPARE_FOR_SUBMISSION",
        "DEVELOPER_REJECTED",
        "REJECTED",
        "METADATA_REJECTED",
        "WAITING_FOR_REVIEW",
    }
    version = None
    for item in versions.get("data") or []:
        state = (item.get("attributes") or {}).get("appStoreState")
        if state in editable_states or state == "PREPARE_FOR_SUBMISSION":
            version = item
            if state != "WAITING_FOR_REVIEW":
                break
    if version is None and versions.get("data"):
        latest = versions["data"][0]
        state = (latest.get("attributes") or {}).get("appStoreState")
        print(f"Latest version state is {state}; creating 1.1.0 if needed")
        if state in {"READY_FOR_SALE", "REPLACED_WITH_NEW_VERSION"}:
            created = api.post(
                "/appStoreVersions",
                {
                    "data": {
                        "type": "appStoreVersions",
                        "attributes": {
                            "platform": "IOS",
                            "versionString": "1.1.0",
                            "copyright": copyright_text,
                        },
                        "relationships": {
                            "app": {"data": {"type": "apps", "id": APP_ID}}
                        },
                    }
                },
            )
            version = created.get("data")
        else:
            version = latest

    if not version:
        raise SystemExit("No iOS App Store version found")

    vid = version["id"]
    state = (version.get("attributes") or {}).get("appStoreState")
    print(f"Using version {vid} state={state}")
    if copyright_text:
        try:
            api.patch(
                f"/appStoreVersions/{vid}",
                {
                    "data": {
                        "type": "appStoreVersions",
                        "id": vid,
                        "attributes": {"copyright": copyright_text},
                    }
                },
            )
        except SystemExit as exc:
            print(f"Copyright patch skipped: {exc}")

    vlocs = api.get(f"/appStoreVersions/{vid}/appStoreVersionLocalizations")
    vloc = (vlocs.get("data") or [None])[0]
    if not vloc:
        raise SystemExit("No version localization")
    api.patch(
        f"/appStoreVersionLocalizations/{vloc['id']}",
        {
            "data": {
                "type": "appStoreVersionLocalizations",
                "id": vloc["id"],
                "attributes": {
                    "description": description,
                    "keywords": keywords,
                    "supportUrl": support,
                    "marketingUrl": marketing,
                    "promotionalText": promo,
                    "whatsNew": whats_new,
                },
            }
        },
    )
    print(f"Updated version localization {vloc['id']}")

    details = api.get(f"/appStoreVersions/{vid}/appStoreReviewDetail")
    detail = details.get("data")
    review_attrs = {
        "contactFirstName": os.environ.get("ASC_CONTACT_FIRST_NAME", "Ercin").strip(),
        "contactLastName": os.environ.get("ASC_CONTACT_LAST_NAME", "Cinar").strip(),
        "contactEmail": os.environ.get("ASC_CONTACT_EMAIL", "ercin312@gmail.com").strip(),
        "contactPhone": os.environ.get("ASC_CONTACT_PHONE", "").strip(),
        "demoAccountName": "diyetisyen@diyetsel.app",
        "demoAccountPassword": "Diyetsel123!",
        "demoAccountRequired": True,
        "notes": review_notes,
    }
    if not review_attrs["contactPhone"]:
        review_attrs.pop("contactPhone")
    payload = {
        "data": {
            "type": "appStoreReviewDetails",
            "attributes": review_attrs,
        }
    }
    if detail:
        payload["data"]["id"] = detail["id"]
        api.patch(f"/appStoreReviewDetails/{detail['id']}", payload)
        print(f"Updated review details {detail['id']}")
    else:
        payload["data"]["relationships"] = {
            "appStoreVersion": {"data": {"type": "appStoreVersions", "id": vid}}
        }
        created = api.post("/appStoreReviewDetails", payload)
        print(f"Created review details {created.get('data', {}).get('id')}")

    print("App Store listing fields filled.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
