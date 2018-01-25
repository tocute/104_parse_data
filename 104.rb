require 'rest-client'
require 'json'
require 'builder'
require 'xmlsimple'

  def get_api(page, pgsz, fmt)
    return "http://www.104.com.tw/i/apis/jobsearch.cfm?page=#{page}&pgsz=#{pgsz}&fmt=#{fmt}&incs=2&sltp=S&slmin=1&cols=JOB,JOB_ADDR_NO_DESCRIPT,NAME,JOBCAT_DESCRIPT,DESCRIPTION,PERIOD,APPEAR_DATE,HANDICOMPENDIUM,SAL_MONTH_LOW,SAL_MONTH_HIGH,MINBINARY_EDU,INDCAT,DRIVER,OTHERS,WELFARE"
  end

  # GET total_page
  total_page = 0;
  page_count = 2000;
  first_api = get_api(1, 1, 8)
  res = RestClient.get(first_api)
  if(res.code == 200)
    rb = JSON.parse(res.body)
    total_page = rb["TOTALPAGE"].to_i / page_count
  else
    puts "ERROR : #{first_api} #{res.code} #{res}"
  end
  puts "total_page #{total_page}";

  result_data = nil;
  for i in 1..total_page
    puts "page #{i}/#{total_page}";

    second_api = get_api(i, page_count, 4);
    res = RestClient.get(second_api)
    if(res.code == 200)
      hash_data = XmlSimple.xml_in(res.body)

      if(result_data == nil)
        result_data = hash_data;
      else
        result_data["JOBITEM"].push(hash_data["JOBITEM"]);
        result_data["PAGECOUNT"] = (result_data["PAGECOUNT"].to_i  + hash_data["PAGECOUNT"].to_i).to_s ;
      end
      
    else
      puts "ERROR : #{second_api} #{res.code} #{res}"
    end
  end
  
  file_time = Time.now().strftime("%Y%m%d_%H%M%S");
  file = File.new("104_data_#{file_time}.xml", "w")
  xml_data = Builder::XmlMarkup.new target: file
  xml_data << XmlSimple.xml_out(result_data)
  file.close