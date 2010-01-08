#---
# Excerpted from "Scripted GUI Testing With Ruby",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/idgtr for more book information.
#---
class PartiesController < ApplicationController
  # GET /parties
  def index
    redirect_to new_party_url
  end
  
  # GET /parties/1
  # GET /parties/1.xml
  def show
    @party = Party.find_by_permalink(params[:id])
    
    guest_name = params[:accept] || params[:decline]
    if guest_name
      guest = Guest.new \
        :party_id => @party.id,
        :name => guest_name,
        :attending => params.has_key?(:accept)
      guest.save
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @party }
      format.text do
        email = PartyMailer.create_invite @party, params[:email]
        render :text => email.encoded
      end
    end
  end

  # GET /parties/new
  # GET /parties/new.xml
  def new
    @party = Party.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @party }
    end
  end

  # POST /parties
  # POST /parties.xml
  def create
    @party = Party.new(params[:party])

    respond_to do |format|
      if @party.save
        recipients = params[:recipients]
        
        if !recipients || recipients.empty?
          flash[:notice] = 'Paste the text below into your e-mail program.'
        else
          recipients.split(',').each do |address|
            email = PartyMailer.deliver_invite @party, address
          end

          flash[:notice] = "Invitations successfully sent to #{recipients}."
        end
        
        format.html { redirect_to(@party) }
        format.xml  { render :xml => @party, :status => :created, :location => @party }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @party.errors, :status => :unprocessable_entity }
      end
    end
  end
end
