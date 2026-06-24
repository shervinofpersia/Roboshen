import os
import json
import requests
import arabic_reshaper
from bidi.algorithm import get_display
from rich.console import Console
from rich.panel import Panel

# تنظیمات اولیه
console = Console()
HISTORY_FILE = os.path.expanduser("~/.roboshen_history.json")
API_URL = "https://text.pollinations.ai/openai"

def load_history():
    """بارگذاری تاریخچه چت از فایل (حداکثر ۲۰ پیام آخر)"""
    if os.path.exists(HISTORY_FILE):
        try:
            with open(HISTORY_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except:
            return []
    return []

def save_history(history):
    """ذخیره تاریخچه چت در فایل"""
    # نگه‌داشتن فقط ۲۰ پیام آخر برای جلوگیری از سنگین شدن ریکوئست
    history = history[-20:]
    try:
        with open(HISTORY_FILE, "w", encoding="utf-8") as f:
            json.dump(history, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def format_persian(text):
    """اصلاح جهت و چسباندن حروف فارسی برای ترمینال"""
    try:
        # چسباندن حروف فارسی
        reshaped_text = arabic_reshaper.reshape(text)
        # راست‌چین کردن
        bidi_text = get_display(reshaped_text)
        return bidi_text
    except Exception:
        return text

def show_header():
    """نمایش هدر و اطلاعات ربات در یک پنل زیبا"""
    os.system('clear' if os.name == 'posix' else 'cls')
    header_text = "[bold cyan]🤖 ROBOSHΞN™ — Terminal AI Agent[/bold cyan]\n"
    header_text += "[yellow]by Shervin Nouri | Telegram: @shervini[/yellow]\n\n"
    header_text += "[white]Commands: exit, /clear, /help[/white]"
    # پنل فقط برای بخش انگلیسی و هدر استفاده می‌شود
    console.print(Panel(header_text, border_style="blue", expand=False))

def main():
    show_header()
    history = load_history()

    while True:
        try:
            print("\n")
            # دریافت پیام کاربر
            user_input = input("You: ").strip()
            
            if not user_input:
                continue
                
            # بررسی دستورات سیستمی
            if user_input.lower() in ['exit', 'quit']:
                console.print("\n[yellow]خداحافظ! 👋[/yellow]\n")
                break
                
            if user_input.lower() == '/clear':
                history = []
                save_history(history)
                show_header()
                console.print(format_persian("[green]تاریخچه چت پاک شد.[/green]"))
                continue
                
            if user_input.lower() == '/help':
                help_text = "دستورات راهنما:\nexit : خروج از برنامه\n/clear : پاک کردن حافظه و تاریخچه ربات"
                print("\n╭── 🤖 ROBOSHΞN ──")
                print(format_persian(help_text))
                print("╰" + "─" * 60)
                continue

            # اضافه کردن پیام کاربر به تاریخچه
            history.append({"role": "user", "content": user_input})

            # آماده‌سازی دیتا برای ارسال به API رایگان
            payload = {
                "messages": history,
                "model": "openai"
            }

            console.print("[dim]در حال فکر کردن...[/dim]", end="\r")
            
            # ارسال درخواست به API
            response = requests.post(API_URL, json=payload)
            
            if response.status_code == 200:
                # پاک کردن متن "در حال فکر کردن..."
                print("\r" + " " * 30 + "\r", end="")
                
                bot_reply = response.text
                
                # تلاش برای استخراج متن در صورتی که خروجی JSON باشد
                try:
                    reply_json = response.json()
                    if "choices" in reply_json:
                        bot_reply = reply_json["choices"][0]["message"]["content"]
                except ValueError:
                    pass # اگر خروجی مستقیماً متن بود (Plain Text)
                    
                # اضافه کردن جواب به تاریخچه و ذخیره آن
                history.append({"role": "assistant", "content": bot_reply})
                save_history(history)
                
                # چاپ جواب ربات (بدون کادر گرافیکی برای جلوگیری از به هم ریختگی فارسی)
                print("╭── 🤖 ROBOSHΞN ──")
                console.print(format_persian(bot_reply), style="bold cyan")
                print("╰" + "─" * 60)

            else:
                print("\r" + " " * 30 + "\r", end="")
                error_msg = f"خطا در ارتباط با سرور: {response.status_code}"
                console.print(format_persian(error_msg), style="bold red")

        except KeyboardInterrupt:
            console.print("\n[yellow]خداحافظ! 👋[/yellow]\n")
            break
        except Exception as e:
            print("\r" + " " * 30 + "\r", end="")
            console.print(f"\n[bold red]یک خطای غیرمنتظره رخ داد: {e}[/bold red]\n")

if __name__ == "__main__":
    main()
