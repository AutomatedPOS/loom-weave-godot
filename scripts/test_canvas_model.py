#!/usr/bin/env python3
"""Shape is a query. These tests fail if a snapshot sneaks in."""

from __future__ import annotations

import json
import sys
import unittest
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from canvas_model import (  # noqa: E402
    ShapeError,
    Unbound,
    bind,
    begun,
    dumps_shape,
    empty_shape,
    is_ghost,
    load_tree,
    parse_shape,
    refill,
    roster_items,
    validate_shape,
)

OP = "aaaaaaaa-aaaa-aaaa-aaaa-000000000001"
OLD = "bbbbbbbb-bbbb-bbbb-bbbb-000000000002"
FUTURE = "cccccccc-cccc-cccc-cccc-000000000003"
GHOST = "dddddddd-dddd-dddd-dddd-000000000004"
ARTIFACT = "eeeeeeee-eeee-eeee-eeee-000000000005"
PERSONA = "13bc00fd-1276-498d-9b35-c2980c5fd10f"
BRIEF = "4a5e6c6b-60bc-423f-8342-010fa057346d"
DAY = date(2026, 9, 4)


def tree() -> list[dict]:
    return [
        {
            "guid": OP,
            "name": "op",
            "type": "operation",
            "actualStart": "2026-09-01",
            "state": "active",
            "isPartOf": "",
            "justDid": "a turn",
            "next": "the next",
            "body": "secret-to-the-shape",
        },
        {
            "guid": OLD,
            "name": "old-work",
            "type": "workItem",
            "actualStart": "2026-09-01",
            "actualEnd": "2026-09-02",
            "state": "done",
            "isPartOf": OP,
            "justDid": "finished",
        },
        {
            "guid": FUTURE,
            "name": "future-work",
            "type": "workItem",
            "actualStart": "2026-09-10",
            "state": "open",
            "isPartOf": OP,
            "body": "not yet",
            "props": [{"name": "pdca", "value": "do"}],
        },
        {
            "guid": GHOST,
            "name": "ghost-plan",
            "type": "workItem",
            "plannedStart": "2026-09-03",
            "plannedEnd": "2026-09-20",
            "isPartOf": OP,
        },
        {
            "guid": ARTIFACT,
            "name": "snap",
            "type": "artifact",
            "actualEnd": "2026-09-03",
            "isPartOf": OP,
        },
        {
            "guid": "e02bd852-910d-4d39-9f62-c37c1440610f",
            "name": "rosters-personas",
            "type": "scopeItem",
            "actualStart": "2026-09-04",
            "isPartOf": OP,
            "props": [{"name": "roster", "value": "personas"}],
        },
        {
            "guid": PERSONA,
            "name": "rosters-personas-brains",
            "type": "scopeItem",
            "actualStart": "2026-09-04",
            "state": "active",
            "isPartOf": "e02bd852-910d-4d39-9f62-c37c1440610f",
            "body": "right hand",
            "props": [{"name": "rail", "value": "persona"}],
        },
        {
            "guid": "e498b6ff-9124-4888-926b-146b2367c676",
            "name": "rosters-processes",
            "type": "scopeItem",
            "actualStart": "2026-09-04",
            "isPartOf": OP,
            "props": [{"name": "roster", "value": "processes"}],
        },
        {
            "guid": BRIEF,
            "name": "rosters-processes-brief",
            "type": "scopeItem",
            "actualStart": "2026-09-04",
            "isPartOf": "e498b6ff-9124-4888-926b-146b2367c676",
            "props": [
                {"name": "rail", "value": "process"},
                {"name": "kind", "value": "actionable"},
            ],
        },
        {
            "guid": "e0fcf2b0-4162-43ce-bbfd-c3b0ed1d5e17",
            "name": "rosters-tools",
            "type": "scopeItem",
            "actualStart": "2026-09-04",
            "isPartOf": OP,
            "props": [{"name": "roster", "value": "tools"}],
        },
        {
            "guid": "ffffffff-ffff-ffff-ffff-000000000006",
            "name": "late-persona",
            "type": "scopeItem",
            "actualStart": "2026-09-20",
            "isPartOf": "e02bd852-910d-4d39-9f62-c37c1440610f",
            "props": [{"name": "rail", "value": "persona"}],
        },
    ]


def node_shape(guid: str, as_of: str = "now") -> dict:
    shape = empty_shape()
    shape["as_of"] = as_of
    shape["windows"].append(
        {"id": "w1", "slot": 0, "ask": {"kind": "node", "guid": guid}}
    )
    return shape


class ShapeStoreTests(unittest.TestCase):
    def test_empty_roundtrip(self) -> None:
        text = dumps_shape(empty_shape())
        again = parse_shape(text)
        self.assertEqual(again["kind"], "shape")
        self.assertEqual(again["windows"][0]["id"], "field")
        self.assertNotIn("body", json.dumps(again))

    def test_reject_body(self) -> None:
        shape = empty_shape()
        shape["body"] = "a snapshot"
        with self.assertRaises(ShapeError):
            validate_shape(shape)

    def test_reject_children_list(self) -> None:
        shape = empty_shape()
        shape["children"] = [{"guid": OP, "body": "no"}]
        with self.assertRaises(ShapeError):
            validate_shape(shape)

    def test_reject_credential(self) -> None:
        shape = empty_shape()
        shape["credential"] = "sk-never"
        with self.assertRaises(ShapeError):
            validate_shape(shape)

    def test_reject_transcript(self) -> None:
        shape = empty_shape()
        shape["windows"][0]["transcript"] = ["hello"]
        with self.assertRaises(ShapeError):
            validate_shape(shape)

    def test_reject_nested_justDid(self) -> None:
        shape = empty_shape()
        shape["windows"][0]["ask"]["justDid"] = "leaked"
        with self.assertRaises(ShapeError):
            validate_shape(shape)

    def test_reject_window_guid_as_id(self) -> None:
        shape = empty_shape()
        shape["windows"][0]["id"] = OP
        with self.assertRaises(ShapeError):
            validate_shape(shape)

    def test_attachment_is_refs_only(self) -> None:
        shape = empty_shape()
        shape["windows"].append(
            {"id": "w1", "slot": 0, "ask": {"kind": "node", "guid": OP}}
        )
        shape["attachments"].append(
            {
                "from": {"kind": "roster", "guid": PERSONA},
                "onto": {"kind": "window", "id": "w1"},
            }
        )
        text = dumps_shape(shape)
        self.assertNotIn("right hand", text)
        self.assertNotIn("secret-to-the-shape", text)
        parsed = parse_shape(text)
        self.assertEqual(parsed["attachments"][0]["from"]["guid"], PERSONA)

    def test_window_onto_window(self) -> None:
        shape = empty_shape()
        shape["windows"].append(
            {"id": "inner", "slot": 0, "ask": {"kind": "none"}}
        )
        shape["attachments"].append(
            {
                "from": {"kind": "window", "id": "inner"},
                "onto": {"kind": "window", "id": "field"},
            }
        )
        validate_shape(shape)

    def test_attachment_cannot_carry_endpoint(self) -> None:
        shape = empty_shape()
        shape["attachments"].append(
            {
                "from": {"kind": "roster", "guid": PERSONA, "endpoint": "https://x"},
                "onto": {"kind": "window", "id": "field"},
            }
        )
        with self.assertRaises(ShapeError):
            validate_shape(shape)


class RefillTests(unittest.TestCase):
    def test_hides_node_that_has_not_begun(self) -> None:
        filled = refill(node_shape(FUTURE, "2026-09-04"), tree(), now=DAY)
        self.assertEqual(filled["panes"]["w1"]["items"], [])
        self.assertFalse(begun(tree()[2], DAY))

    def test_includes_done_node_after_its_end(self) -> None:
        filled = refill(node_shape(OLD, "2026-09-04"), tree(), now=DAY)
        items = filled["panes"]["w1"]["items"]
        self.assertEqual(len(items), 1)
        self.assertEqual(items[0]["guid"], OLD)
        self.assertEqual(items[0]["justDid"], "finished")
        self.assertFalse(items[0]["ghost"])

    def test_shape_does_not_gain_the_refill(self) -> None:
        shape = node_shape(OP, "2026-09-04")
        before = dumps_shape(shape)
        refill(shape, tree(), now=DAY)
        self.assertEqual(dumps_shape(shape), before)
        self.assertNotIn("secret-to-the-shape", before)
        self.assertNotIn("justDid", before)

    def test_refill_at_two_days_is_two_reads_of_one_query(self) -> None:
        shape = empty_shape()
        shape["windows"].append(
            {"id": "w1", "slot": 0, "ask": {"kind": "roster", "rail": "personas"}}
        )
        early = dict(shape)
        early["as_of"] = "2026-09-03"
        late = dict(shape)
        late["as_of"] = "2026-09-04"
        early_items = refill(early, tree(), now=DAY)["panes"]["w1"]["items"]
        late_items = refill(late, tree(), now=DAY)["panes"]["w1"]["items"]
        self.assertEqual(early_items, [])
        names = [i["name"] for i in late_items]
        self.assertIn("rosters-personas-brains", names)
        self.assertNotIn("late-persona", names)

    def test_artifact_exists_from_its_actualEnd(self) -> None:
        before = refill(node_shape(ARTIFACT, "2026-09-02"), tree(), now=DAY)
        after = refill(node_shape(ARTIFACT, "2026-09-03"), tree(), now=DAY)
        self.assertEqual(before["panes"]["w1"]["items"], [])
        self.assertEqual(after["panes"]["w1"]["items"][0]["guid"], ARTIFACT)

    def test_undated_is_ghost_every_day(self) -> None:
        undated = {
            "guid": "aaaaaaaa-aaaa-aaaa-aaaa-000000000099",
            "name": "undated",
            "type": "workItem",
            "isPartOf": OP,
        }
        self.assertTrue(is_ghost(undated, date(1970, 1, 1)))
        self.assertTrue(is_ghost(undated, DAY))

    def test_planned_is_ghost_inside_the_plan(self) -> None:
        filled = refill(node_shape(GHOST, "2026-09-04"), tree(), now=DAY)
        self.assertTrue(filled["panes"]["w1"]["items"][0]["ghost"])

    def test_kids_hide_the_future_sibling(self) -> None:
        shape = empty_shape()
        shape["as_of"] = "2026-09-04"
        shape["windows"].append(
            {"id": "w1", "slot": 0, "ask": {"kind": "kids", "guid": OP}}
        )
        names = [i["name"] for i in refill(shape, tree(), now=DAY)["panes"]["w1"]["items"]]
        self.assertIn("old-work", names)
        self.assertNotIn("future-work", names)
        self.assertIn("ghost-plan", names)

    def test_pdca_hides_future_open_work(self) -> None:
        shape = empty_shape()
        shape["as_of"] = "2026-09-04"
        shape["windows"][0]["ask"] = {"kind": "pdca"}
        items = refill(shape, tree(), now=DAY)["panes"]["field"]["items"]
        self.assertEqual(items, [])

    def test_hours_do_not_change_the_read(self) -> None:
        morning = node_shape(OLD, "2026-09-04T09:00:00Z")
        afternoon = node_shape(OLD, "2026-09-04T14:00:00Z")
        a = refill(morning, tree(), now=DAY)
        b = refill(afternoon, tree(), now=DAY)
        self.assertEqual(a["as_of"], b["as_of"])
        self.assertEqual(a["panes"]["w1"]["items"], b["panes"]["w1"]["items"])

    def test_tools_roster_is_empty(self) -> None:
        items = roster_items(tree(), "tools", DAY)
        self.assertEqual(items, [])


class PipeTests(unittest.TestCase):
    def test_unbound_without_endpoint(self) -> None:
        loadout = {
            "chat": {"endpoint": "", "credential": "sk-never", "model": ""},
            "speech": {"endpoint": "", "credential": "", "model": ""},
            "hear": {"endpoint": "", "credential": "", "model": ""},
        }
        with self.assertRaises(Unbound):
            bind(PERSONA, loadout, tree())

    def test_bind_does_not_copy_the_credential(self) -> None:
        loadout = {
            "chat": {
                "endpoint": "https://example.invalid/v1",
                "credential": "sk-never",
                "model": "x",
            }
        }
        binding = bind(PERSONA, loadout, tree())
        self.assertEqual(binding, {"persona": PERSONA, "cap": "chat"})
        blob = json.dumps(binding)
        self.assertNotIn("sk-never", blob)
        self.assertNotIn("endpoint", blob)
        self.assertNotIn("example.invalid", blob)

    def test_bind_rejects_a_process_guid(self) -> None:
        loadout = {"chat": {"endpoint": "https://example.invalid/v1"}}
        with self.assertRaises(Unbound):
            bind(BRIEF, loadout, tree())


class RepoTreeTests(unittest.TestCase):
    def test_repo_rosters_match_the_named_three(self) -> None:
        nodes = load_tree(ROOT)
        day = date(2026, 9, 4)
        names = [n["name"] for n in roster_items(nodes, "personas", day)]
        self.assertEqual(
            sorted(names),
            [
                "rosters-personas-archivus",
                "rosters-personas-brains",
                "rosters-personas-fixer",
            ],
        )
        process_names = [n["name"] for n in roster_items(nodes, "processes", day)]
        self.assertEqual(process_names, ["rosters-processes-brief"])
        self.assertEqual(roster_items(nodes, "tools", day), [])


if __name__ == "__main__":
    unittest.main()
