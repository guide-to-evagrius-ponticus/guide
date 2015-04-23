<%@ Page Explicit="True" Language="VB" Debug="True" %>
<%@ import Namespace="System.Web.Mail" %>
<script runat="server">

    Sub Page_Load(Sender as Object, E as EventArgs)
    If IsPostBack=False Then
        Session("Topic") = Request.QueryString("Topic")
        If Not Request.UrlReferrer Is Nothing Then
            Session("FromPg") = Request.UrlReferrer.ToString()
        Else
            Session("FromPg") = ".."
        End If
    End If
    End Sub


    Sub btnSendMail_Click(sender as object, E as EventArgs)
    Dim EMailTo as String = "joel@sacredpresence.com"
    Dim EMailFrom as String = txtEmail.Text
    Dim EMailSubject as String = "[GEP] " & txtSubject.text
    Dim EmailBody as String = txtMessage.Text
        If (Page.IsValid)
            SmtpMail.SmtpServer = "smtp.sacredpresence.com"
            SmtpMail.Send(EmailFrom, EMailTo, EMailSubject, EMailBody)
            pnlForm.Visible = false
            pnlThankYou.Visible = true
        End If
    End Sub

</script>


<!DOCTYPE html>
<html>
    <head>
        <title>Guide to Evagrius Ponticus: Contact form</title>
        <link rel="stylesheet" type="text/css" href="default.css" />
        <link rel="shortcut icon" href="favicon.ico" />
        <link href="atom.xml" type="application/atom+xml" rel="alternate" title="Sitewide ATOM Feed" />
        <script type="text/javascript" src="scripts/jquery.js"></script>
        <script type="text/javascript" src="scripts/banner.js"></script>
        
        <!--Google Analytics-->
        <script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-27587668-1']);
  _gaq.push(['_setDomainName', 'evagriusponticus.net']);
  _gaq.push(['_setAllowLinker', true]);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

        </script>
        <!-- mark header for the current page -->
        <style type="text/css">
			a[href = 'index.htm'] {
			    font-weight : bolder;
			}</style>
    </head>
    <body>
        <script type="text/javascript">
		document.write(fBanner());
	</script>
        <article>
    <form runat="server">
                                    <h2>
                                        <%= Session("Topic")%>&nbsp;Contact Form&nbsp;
                                    </h2>
                                        <asp:Panel id="pnlForm" runat="server">
                                                            <p >
                                                                Your Name:
                                                            <asp:TextBox id="txtName" runat="server" columns="35"></asp:TextBox>
                                                            <asp:RequiredFieldValidator id="RequiredFieldValidator1" runat="server" Text="* Name is a required field." ControlToValidate="txtName"></asp:RequiredFieldValidator>
                                                            </p>
                                                            <p>
                                                                Your e-mail address:
                                                            <asp:TextBox id="txtEmail" runat="server" columns="35"></asp:TextBox>
                                                            <asp:RequiredFieldValidator id="RequiredFieldValidator2" runat="server" Text="* Email is a required field." ControlToValidate="txtEmail" Display="dynamic"></asp:RequiredFieldValidator>
                                                            </p>
                                                            <p>
                                                                Subject:
                                                            <asp:TextBox id="txtSubject" runat="server" columns="35"></asp:TextBox>
                                                            <asp:RequiredFieldValidator id="RequiredFieldValidator3" runat="server" Text="* Subject is a required field." ControlToValidate="txtSubject" Display="dynamic"></asp:RequiredFieldValidator>
                                                        </p>
                                                            <p>
                                                                Message:
                                                            <asp:TextBox id="txtMessage" runat="server" columns="45" textmode="multiline" rows="7"></asp:TextBox>
                                                            <asp:RequiredFieldValidator id="RequiredFieldValidator4" runat="server" Text="* Please type a message." ControlToValidate="txtMessage" Display="dynamic"></asp:RequiredFieldValidator>
                                                            </p>
                                                            <asp:Button id="btnSendMail" onclick="btnSendMail_Click" runat="server" text="Send Mail"></asp:Button>
                                        </asp:Panel>
                                        <asp:Panel id="pnlThankYou" runat="server" Visible="false">
                                            <div>
                                                <p>
                                                    Thank you for your inquiry. Your message has been sent.
                                                </p>
                                                <p>
                                                    <a href="<%= Session("FromPg")%>"&gt;Return to page you last visited</a>
                                                </p>
                                            </div>
                                        </asp:Panel>
    </form>
        </article>
        <script type="text/javascript">
		document.write(evfooter());
	</script>
    </body>
</html>
