class String
  # 获取字符串的所有数字
  def get_all_num
    num_array = self.scan(/\d/)
    num_array.join(',').gsub(',', '').to_i
  end
end