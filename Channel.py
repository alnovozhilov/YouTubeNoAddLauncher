from PyQt5.QtCore import QObject
from bs4 import BeautifulSoup as bs
from PyQt5.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QVariant
from threading import Thread
import requests
import os
import sqlite3
import json


class Channel(QObject):
	def __init__(self):
		QObject.__init__(self)

		self.db = sqlite3.connect('data_base.db')
		
		self.mirror_url = ""
		self.channel_url = ""
		self.soup = ""
		self.channel_name = ""
		self.header_url = ""
		self.avatar_url = ""
		self.videos_info = {}

	selectURL = pyqtSignal(str, arguments=['URL'])

	@pyqtProperty(str)
	def get_mirror_url(self):
		return self.mirror_url

	@pyqtProperty(str)
	def get_channel_url(self):
		return self.channel_url

	@pyqtProperty(str)
	def get_channel_name(self):
		return self.channel_name

	@pyqtProperty(str)
	def get_header_url(self):
		return self.header_url

	@pyqtProperty(str)
	def get_avatar_url(self):
		return self.avatar_url

	@pyqtProperty(QVariant)
	def get_videos_info(self):
		return self.videos_info

	@pyqtProperty(list)
	def select_all_channels(self):
		cur = self.db.cursor()
		cur.execute("SELECT * FROM channels;")
		channels_list = cur.fetchall()
		json_list = []
		for channel in channels_list:
			json_str = json.dumps(channel)
			json_list.append(json.loads(json_str))
		return json_list

	@pyqtSlot(str)
	def select_channel_url(self, channel_name):
		cur = self.db.cursor()
		cur.execute("SELECT url FROM channels WHERE name = \"" + channel_name + "\";")
		self.selectURL.emit(cur.fetchone()[0])

	@pyqtSlot(str)
	def insert_channel(self, channel_url):
		cur = self.db.cursor()
		self.set_channel_url(channel_url)
		self.parse_page()
		self.avatar_parsing()
		cur.execute("INSERT INTO channels ( name, url ) VALUES ( \'" + self.channel_name + "\', \'" + channel_url + "\' );")
		self.db.commit()

	@pyqtSlot(str)
	def delete_channel(self, channel_name):
		cur = self.db.cursor()
		cur.execute("DELETE FROM channels WHERE name = \'" + channel_name  + "\';")
		self.db.commit()

	@pyqtSlot(str)
	def set_mirror_url(self, mirror_url):
		self.mirror_url = mirror_url

	@pyqtSlot(str)
	def set_channel_url(self, channel_url):
		self.channel_url = channel_url.split("channel")[1]

	@pyqtSlot(str)
	def set_channel_name(self, channel_name):
		self.channel_name = channel_name

	@pyqtSlot()
	def parse_page(self):
		source = requests.get(self.mirror_url + "/channel" + self.channel_url)
		source.encoding = 'utf-8'
		self.soup = bs(source.text, 'html.parser')

	@pyqtSlot()
	def thread_parse_page(self):
		th = Thread(target=self.parse_page)
		th.start()

	@pyqtSlot()
	def avatar_parsing(self):
		name = self.soup.select("span")
		images = self.soup.select("img")
		name1 = name[1]
		self.channel_name = (name1.text)
		self.header_url = self.mirror_url + images[0]['src']
		self.avatar_url = self.mirror_url + images[1]['src']

		p = requests.get(self.header_url)
		out = open("./recourses/headers/" + self.channel_name + ".jpg", "wb")
		out.write(p.content)
		p = requests.get(self.avatar_url)
		out = open("./recourses/avatars/" + self.channel_name + ".jpg", "wb")
		out.write(p.content)
		out.close()

	@pyqtSlot()
	def video_parsing(self):
		videos = self.soup.findAll("a", {"style": "width:100%"})
		videos_urls = []
		videos_titles = []
		videos_preview_urls = []
		videos_lengths = []
		for i in range(0, len(videos)):
			title = videos[i].find("p", {"dir": "auto"})
			preview_url = videos[i].find("img")
			length = videos[i].find("p", {"class": "length"})

			videos_urls.append(self.mirror_url + videos[i]["href"])
			videos_titles.append(title.text)
			videos_preview_urls.append(self.mirror_url + preview_url["src"])
			videos_lengths.append(length.text)

		self.videos_info["videos_urls"] = videos_urls
		self.videos_info["videos_titles"] = videos_titles
		self.videos_info["videos_preview_urls"] = videos_preview_urls
		self.videos_info["videos_lengths"] = videos_lengths

	@pyqtSlot(str)
	def execVideo(self, video_url):
		th = Thread(target=os.system, args=("mpv " + video_url, ))
		th.start()