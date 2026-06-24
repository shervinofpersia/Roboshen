#!/usr/bin/env python3
# roboshen - ROBOSHΞN™ Terminal AI Agent

import os
import sys
import json
import subprocess
import requests
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.prompt import Prompt
from rich.text import Text
from rich import box
from time import sleep

# ===== SYSTEM PROMPT (English instructions, Pinglish output) =====
SYSTEM_PROMPT = """You are ROBOSHΞN™, an AI assistant running in a terminal (Termux/Linux).
Creator: Shervin Nouri
Contact: Telegram @shervini (https://t.me/shervini)

IMPORTANT RULES:
1. LANGUAGE:
   - If user writes in English → respond in English.
   - If user writes in Persian (Farsi) or Pinglish (Farsi using Latin letters) → respond in Pinglish (Farsi with Latin letters).
   - attention: NEVER use Persian/Arabic characters or script in your responses (use only Latin letters for Farsi).

2. INTRODUCTION:
   - ONLY introduce yourself (as ROBOSHΞN™) in the VERY FIRST message of the conversation.
   - After that, DO NOT reintroduce yourself in every response. Just give the answer directly.
   - No greetings like "Salam!" or "Hello!" in every message. Just be direct and helpful.

3. BEHAVIOR:
   - Be friendly, accurate, and creative.
   - If user asks technical questions, give step-by-step complete answers.
   - If question is off-topic, politely guide them.
   - Avoid slang or overly casual language, but be warm and natural.
   - If needed, give useful suggestions for improving terminal work.

4. FORMAT:
   - Keep responses clear and readable.
   - Use simple formatting (no markdown if not needed).
   - If listing steps, use numbers or bullet points with "-".

Remember: You are an AI agent. Respond in Pinglish (Farsi with Latin letters) unless user writes in English, then respond in English. Never use Persian script."""
MODEL = "openai-fast"
API_URL = "https://text.pollinations.ai/openai"
MAX_HISTORY = 20

console = Console()

# ===== check font =====
def check_font_persian():
    try:
        result = subprocess.run(["fc-list", ":lang=fa"], capture_output=True, text=True, timeout=5)
        if result.stdout.strip():
            return True
    except:
        pass
    return False

# ===== Chat Session =====
class ChatSession:
    def __init__(self):
        self.messages = [{"role": "system", "content": SYSTEM_PROMPT}]
        self.history_file = os.path.expanduser("~/.roboshen_history.json")
        self.load_history()
        self.first_message = True

    def load_history(self):
        if os.path.exists(self.history_file):
            try:
                with open(self.history_file, "r") as f:
                    data = json.load(f)
                    if isinstance(data, list):
                        self.messages = [self.messages[0]] + data[-MAX_HISTORY:]
            except:
                pass

    def save_history(self):
        try:
            with open(self.history_file, "w") as f:
                json.dump(self.messages[1:], f, ensure_ascii=False, indent=2)
        except:
            pass

    def add_user_message(self, text):
        self.messages.append({"role": "user", "content": text})
        self.save_history()

    def add_assistant_message(self, text):
        self.messages.append({"role": "assistant", "content": text})
        self.save_history()

    def get_recent_messages(self):
        return [self.messages[0]] + self.messages[-10:]

    def clear_history(self):
        self.messages = [{"role": "system", "content": SYSTEM_PROMPT}]
        self.first_message = True
        if os.path.exists(self.history_file):
            os.remove(self.history_file)

# ===== Call API =====
def call_api(messages, retry=0):
    try:
        response = requests.post(
            API_URL,
            json={"model": MODEL, "messages": messages, "private": True},
            timeout=45
        )
        if response.status_code == 429 and retry < 2:
            console.print("[yellow]Rate limit, waiting...[/yellow]")
            sleep(4)
            return call_api(messages, retry+1)
        if response.status_code != 200:
            return None, f"HTTP {response.status_code}: {response.text[:200]}"
        data = response.json()
        reply = data.get("choices", [{}])[0].get("message", {}).get("content")
        if reply is None:
            return None, "No content in response."
        return reply, None
    except Exception as e:
        return None, str(e)

# ===== Main =====
def main():
    if not check_font_persian():
        console.print("[yellow]Warning: Persian font not found. Some characters may not display correctly.[/yellow]")

    chat = ChatSession()
    console.clear()

    header = Panel(
        Text("🤖 ROBOSHΞN™ — Terminal AI Agent", style="bold cyan"),
        subtitle=Text("by Shervin Nouri | Telegram: @shervini", style="dim"),
        border_style="bright_blue",
        box=box.HEAVY,
        padding=(1, 2)
    )
    console.print(header)
    console.print("[dim]Commands: exit, /clear, /help[/dim]\n")

    while True:
        try:
            user_input = Prompt.ask("\n[bold green]You[/bold green]")
        except (KeyboardInterrupt, EOFError):
            console.print("\n[red]Exit.[/red]")
            break

        if not user_input:
            continue

        if user_input.lower() in ("exit", "quit"):
            break
        elif user_input.strip() == "/clear":
            chat.clear_history()
            console.print("[yellow]History cleared.[/yellow]")
            continue
        elif user_input.strip() == "/help":
            console.print(Panel(
                "Commands:\n  exit / quit  - exit program\n  /clear       - clear chat history\n  /help        - show this help",
                title="Help",
                border_style="green"
            ))
            continue

        chat.add_user_message(user_input)

        with console.status("[bold yellow]ROBOSHΞN™ thinking...[/bold yellow]"):
            reply, error = call_api(chat.get_recent_messages())

        if error:
            console.print(f"[red]Error: {error}[/red]")
            chat.messages.pop()
            continue

        chat.add_assistant_message(reply)

        console.rule(style="dim")
        console.print(Panel(
            Markdown(reply),
            title="🤖 ROBOSHΞN™",
            border_style="magenta",
            box=box.ROUNDED,
            padding=(1, 2)
        ))
        console.rule(style="dim")

    console.print("\n[green]Goodbye![/green]")

if __name__ == "__main__":
    main()
