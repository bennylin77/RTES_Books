# encoding: utf-8
class SystemMailer < ActionMailer::Base
  default :from=> "RTES books"
  add_template_helper (ApplicationHelper)
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.system_mailer.test.subject
  #

  def send_notification(list=nil,list_sended=nil, type=nil)
    @list=list
    if type=="requesting"
      @type="requesting"
      mail( to: list_sended.user.email , subject:"有人在販賣 \""+list.book_list.name+"\"")
    elsif type=="selling"
      @type="selling"    
      mail( to: list_sended.user.email , subject:"有人在徵求 \""+list.book_list.name+"\"")      
    end
  end
  
  def sendFBCommentNotification(list_sended=nil, type=nil, user=nil, comment=nil)
    @list_sended=list_sended
    @user=user
    @comment=comment
    if type=="requesting"
      @type="requesting"
      mail( to: list_sended.user.email , subject:"有人在 \""+list_sended.book_list.name+"\" 下留言")
    elsif type=="selling"
      @type="selling"    
      mail( to: list_sended.user.email , subject:"有人在 \""+list_sended.book_list.name+"\" 下留言")      
    end
  end
  
end
