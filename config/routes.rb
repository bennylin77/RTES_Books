RTESBooks::Application.routes.draw do
  
  resources :user_configs, :only => [:edit, :update]
  get  "main/index"
  get  "main/indexSelect"

  get  "main/schoolOutline"
  get  "main/allOutline"   
  get  "main/sendMessagejs"       
  get  "main/showSellingBook" 
  get  "main/showRequestingBook" 
  get  "main/areaListShowing"
  get  "main/allListShowing"
  get  "main/allList"
  
  get  "main/requestingPage1"
  post "main/requestingPage2"
  post "main/requestingPage3Save"

  get  "main/sellingPage1"
  post "main/sellingPage2"
  post "main/sellingPage3Save"

  get  "main/auto_complete_for_book_list_name"
  get  "main/auto_complete_for_book_list_isbn"
  get  "main/auto_complete_for_book_list_author"
  get  "main/auto_complete_for_SearchBookList"
  get  "main/post_on_fb"
  get  "main/fbCommentNotification"
  get  "main/friendsBookLists"
  get  "main/myBookLists"
  post "main/zxing"
  

 match 'my_selling/:id' => 'my_selling#show', :via => :get
 match 'my_selling/:id/edit' => 'my_selling#edit', :via => :get
 match 'my_selling/:id/edit' => 'my_selling#update', :via => :put
 match 'my_selling/:id' => 'my_selling#destroy', :via => :delete
 match 'my_selling/:id/repost' => 'my_selling#repost', :via => :get
 match 'my_selling/:id/unavailable' => 'my_selling#unavailable', :via => :get 

 match 'my_requesting/:id' => 'my_requesting#show', :via => :get
 match 'my_requesting/:id/edit' => 'my_requesting#edit', :via => :get
 match 'my_requesting/:id/edit' => 'my_requesting#update', :via => :put
 match 'my_requesting/:id' => 'my_requesting#destroy', :via => :delete
 match 'my_requesting/:id/repost' => 'my_requesting#repost', :via => :get
 match 'my_requesting/:id/unavailable' => 'my_requesting#unavailable', :via => :get
  root :to => 'main#indexSelect'

  resource :facebook, :except => :create do
      get :callback, :to => :create
  end
end
