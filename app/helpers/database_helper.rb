#encoding: utf-8
module DatabaseHelper

require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'timeout'

TIMEOUT_CNT = 42

  def egen_print_info code
    retries = TIMEOUT_CNT
    begin
      Timeout::timeout(5) {
        ret = []
        doc = Nokogiri::HTML(open("http://www.e-gen.or.kr/egen/inf.AED2.do?yearSeq=#{code}?HPID="))
        doc.xpath('//ul/li').each do |a|
          header, data = a.text.gsub(/[\t]/, '').gsub(/\r\n/, ' ').gsub(/,/,'_').split(': ')
          ret.push(data)
        end
        ret.push([doc.at('input[@name="LON"]')['value'].to_f, doc.at('input[@name="LAT"]')['value'].to_f])
        ret
      }
    rescue Timeout::Error
      retries -= 1
      if retries > 0 
        puts "sleep"
        sleep 1.42
        retry
      else
        puts "raise"
        raise
      end
    end
  end # def egen_print_info

  def egen_get_list n
    retries = TIMEOUT_CNT
    elements = nil
    begin
      cnt = 0
      Timeout::timeout(5) {
        uri = URI("http://www.e-gen.or.kr/egen/inf.AED1.do?lon=&lat=&cnt=2444&str_cnt=0&page_num=1&page_size=100000&radius=400000&x=20&y=15&page=#{n}")
        req = Net::HTTP::Get.new(uri.request_uri)
        req['cookie'] = "dong=null; lat=12675299; lon=46433849; sido=%25; sigungu=; JSESSIONID=FA638CB737D45369ED485C5106492BB3; DWRSESSIONID=c6JMSsrbcCyyepBSnFHBm9b$Tyk"
        res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
        doc = Nokogiri::HTML(res.body) # cookie sido = %25
        elements = doc.xpath('//td/b/a')
      }
    rescue Timeout::Error
      retries -= 1
      if retries > 0 
        puts "sleep"
        sleep 1.42
        retry
      else
        puts "raise"
        raise
      end
    end
    elements
  end # def egen_get_list


  def hira_get_code_list n # n = 1 # 500 # 1614
    retries = TIMEOUT_CNT
    begin
      Timeout::timeout(5) {
        ret = []
        cnt = 0
        code = ""
        doc = Nokogiri::HTML(open("http://m.hira.or.kr/eva/list.do?cateID=&p=#{n}"))
        doc.xpath('//li/a').each do |a|
          code = a['href'].scan(/code=(.*)/)
          if !code.empty?
            cnt = cnt + 1 # if retries >= TIMEOUT_CNT
            code = code.join()
            # puts "#{n},#{cnt},#{code},'list',#{retries}"
            ret.push(code)
          end
        end #doc.xpath
        ret
      }
    rescue Timeout::Error
      retries -= 1
      if retries > 0 
        puts "sleep"
        sleep 1.42
        retry
      else
        puts "raise"
        raise
      end
    end
  end # hira_get_code_list

  def hira_print_info code
    retries = TIMEOUT_CNT
    begin
      Timeout::timeout(5) {
        ret = {}
        info_dt = []
        info_dd = []
        doc = Nokogiri::HTML(open("http://m.hira.or.kr/eva/data.do?view=hos&code=#{code}"))
        doc.xpath('//h3').each do |a|
          info_dt << "병원이름"
          info_dd << a.inner_text
        end
        doc.xpath('//dl/dt').each do |a|
          info_dt << a.inner_text.scan(/(.*) :/).join
        end
        doc.xpath('//dl/dd').each do |a|
          info_dd << a.inner_text
        end
        
        doc.xpath('//table/tbody/tr/th').each do |a|
          info_dt << a.inner_text
        end
        doc.xpath('//table/tbody/tr/td').each do |a|
          info_dd << a.inner_text
        end

        while info_dt.length < info_dd.length
          info_dd.pop
        end
        
        while !info_dt.empty?
          idt = info_dt.pop
          idd = info_dd.pop
          ret[idt] = idd
          # puts  code + "," + idt + "," + idd
        end
        ret
      }
    rescue Timeout::Error
      retries -= 1
      if retries > 0 
        puts "sleep"
        sleep 1.42
        retry
      else
        puts "raise"
        raise
      end
    end
  end # def hira_print_info

  def hira_print_grade code
    retries = TIMEOUT_CNT
    begin
      Timeout::timeout(5) {
        ret = {}
        info_dt = []
        info_dd = []
        doc = Nokogiri::HTML(open("http://m.hira.or.kr/eva/data.do?view=eva&code=#{code}"))
        doc.xpath('//dl/dt').each do |a|
          info_dt << a.inner_text
        end
        doc.xpath('//dl/dd/figure').each do |a|
          a.children.each do |x| 
            info_dd << x['alt'] if x.name == "img"
            info_dd << "" if x.name == "span"
          end
        end
        while !info_dt.empty?
          idt = info_dt.pop
          idd = info_dd.pop
          ret[idt] = idd.to_i
          # puts  code + "," + idt + "," + idd
        end
        ret
      }
    rescue Timeout::Error
      retries -= 1
      if retries > 0 
        puts "sleep"
        sleep 1.42
        retry
      else
        puts "raise"
        raise
      end
    end
  end # def hira_print_grade
end